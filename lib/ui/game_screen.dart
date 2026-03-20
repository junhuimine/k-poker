/// 🎴 K-Poker — 메인 게임 화면 (애니메이션 버전)
///
/// 딜링, 카드 던짐, 획득 날아오기 등 전체 카드 모션 시스템 포함

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_providers.dart';
import '../state/card_skin_provider.dart';
import '../engine/game_engine.dart';
import '../state/audio_manager.dart';
import '../i18n/locale_provider.dart';
import '../models/card_def.dart';
import '../data/stage_config.dart';
import 'widgets/hwatu_card.dart';
import 'widgets/card_animation_overlay.dart';
import 'settings_overlay.dart';
import 'tutorial_overlay.dart';
import 'shop_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  // 딜링 애니메이션 상태
  bool _isDealing = false;
  List<FlyingCard> _flyingCards = [];
  
  // 딜링 중 보여줄 카드 수 (점진적 증가)
  int _dealtOpponentCount = 0;
  int _dealtFieldCount = 0;
  int _dealtPlayerCount = 0;
  int _visibleDeckCount = 48; // 시작 시 전체 덱

  // 카드 선택 상태 (같은 월 2장 이상일 때)
  CardInstance? _pendingPlayedCard;
  List<CardInstance> _selectableFieldCards = [];

  // 설정/튜토리얼 오버레이
  bool _showSettings = false;
  bool _showShop = false;
  bool _showTutorial = false;

  // ─── 반응형 UI 헬퍼 (화면 비율 기반) ─────────────────
  double get _screenW => MediaQuery.of(context).size.width;
  double get _screenH => MediaQuery.of(context).size.height;
  // 기준 해상도 대비 스케일 팩터 (1200x700 기준)
  double get _scaleW => (_screenW / 1200).clamp(0.4, 1.5);
  double get _scaleH => (_screenH / 700).clamp(0.4, 1.5);
  double get _scale => (_scaleW < _scaleH ? _scaleW : _scaleH); // 작은 쪽 기준
  bool get _showSidePanel => _screenW >= 700;

  // 카드 크기 (화면 비율에 따라 부드럽게 스케일)
  double get _opponentCardSize => (38 * _scale).clamp(20, 50);
  double get _fieldCardSize => (70 * _scale).clamp(35, 90);
  double get _playerCardSize => (72 * _scale).clamp(40, 95);
  double get _capturedCardSize => (45 * _scale).clamp(22, 55);
  double get _capturedFanHeight => (70 * _scale).clamp(38, 85);

  // 레이아웃 수치 (화면 비율 기반)
  double get _opponentHandHeight => (70 * _scaleH).clamp(35, 80);
  double get _playerHandHeight => (145 * _scaleH).clamp(80, 160);
  double get _capturedAreaHeight => (75 * _scaleH).clamp(38, 85);
  double get _fieldMinHeight => (140 * _scaleH).clamp(70, 160);
  double get _fontSize => (13 * _scale).clamp(9, 16);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 앱 시작 시 저장된 게임 자동 불러오기
    if (!_loadAttempted) {
      _loadAttempted = true;
      ref.read(runStateNotifierProvider.notifier).loadGame().then((_) {
        // 로드 후 상대 자금 보정
        ref.read(runStateNotifierProvider.notifier).fixOpponentMoney();
      });
    }
  }

  bool _loadAttempted = false;

  /// 게임 시작 + 딜링 애니메이션
  void _startGameWithDeal() {
    ref.read(gameStateProvider.notifier).startGame();
    AudioManager().startBgmLoop(); // BGM 10곡 순환 시작
    final gameState = ref.read(gameStateProvider);

    setState(() {
      _isDealing = true;
      _dealtOpponentCount = 0;
      _dealtFieldCount = 0;
      _dealtPlayerCount = 0;
      _visibleDeckCount = 48;
      _flyingCards = [];
    });

    // 딜링 시퀀스: 덱 위치에서 각 영역으로 한 장씩
    _runDealSequence(gameState);
  }

  void _runDealSequence(dynamic gameState) async {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    // 덱 위치 (왼쪽 중앙)
    final deckPos = Offset(30, screenH * 0.4);

    // 상대 핸드 영역 (상단 중앙)
    final opponentBaseX = screenW * 0.3;
    const opponentY = 60.0;

    // 필드 영역 (중앙)
    final fieldBaseX = screenW * 0.25;
    final fieldY = screenH * 0.35;

    // 플레이어 핸드 영역 (하단)
    final playerBaseX = screenW * 0.2;
    final playerY = screenH - 150.0;

    final dealOrder = <_DealTarget>[];

    // 고스톱 딜링 순서: 상대3 → 필드4 → 나3 → 상대3 → 필드4 → 나3 → ...
    // 단순화: 필드8 → 상대10 → 나10
    for (int i = 0; i < 8; i++) {
      dealOrder.add(_DealTarget('field', i));
    }
    for (int i = 0; i < 10; i++) {
      dealOrder.add(_DealTarget('opponent', i));
    }
    for (int i = 0; i < 10; i++) {
      dealOrder.add(_DealTarget('player', i));
    }

    for (final target in dealOrder) {
      if (!mounted) return;

      Offset to;
      CardInstance card;
      bool faceDown = false;

      switch (target.area) {
        case 'field':
          to = Offset(fieldBaseX + target.index * 65, fieldY);
          card = gameState.field[target.index];
          break;
        case 'opponent':
          to = Offset(opponentBaseX + target.index * 42, opponentY);
          card = gameState.opponentHand[target.index];
          faceDown = true;
          break;
        case 'player':
          to = Offset(playerBaseX + target.index * 78, playerY);
          card = gameState.playerHand[target.index];
          break;
        default:
          continue;
      }

      // 카드 하나 날려보내기
      final random = Random();
      final throwAngle = (random.nextDouble() - 0.5) * 0.15; // 약간의 랜덤 회전

      setState(() {
        _visibleDeckCount--;
        _flyingCards = [
          FlyingCard(
            card: card,
            from: deckPos,
            to: to,
            startAngle: -0.3,
            endAngle: throwAngle,
            isFaceDown: faceDown,
            duration: const Duration(milliseconds: 500),
            size: faceDown ? 38 : (target.area == 'field' ? 50 : 72),
          ),
        ];
      });

      await Future.delayed(const Duration(milliseconds: 300));

      // 해당 영역에 카드 추가
      setState(() {
        switch (target.area) {
          case 'field':
            _dealtFieldCount = target.index + 1;
            break;
          case 'opponent':
            _dealtOpponentCount = target.index + 1;
            break;
          case 'player':
            _dealtPlayerCount = target.index + 1;
            break;
        }
      });
    }

    // 딜링 완료
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _isDealing = false;
        _flyingCards = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final strings = ref.watch(appStringsProvider);
    final isGoStopPending = ref.watch(goStopPendingProvider);
    final aiGoStopAnnounce = ref.watch(aiGoStopAnnounceProvider);
    final events = ref.watch(gameEventsProvider);
    final isGameStarted = gameState.deck.isNotEmpty || gameState.isFinished || _isDealing;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          _buildDynamicBackground(gameState.playerScore),

          SafeArea(
            child: Row(
              children: [
                Expanded(
                  flex: 75,
                  child: Column(
                    children: [
                      // 상단 영역: 상대 정보 + 뒷면 핸드 + 상대 획득 카드
                      if (isGameStarted) _buildTopBar(gameState, strings),
                      if (isGameStarted) _buildOpponentInfoBar(gameState),
                      if (isGameStarted) _buildOpponentHand(gameState),
                      if (isGameStarted) _buildCapturedArea(gameState.opponentCaptured, '상대 획득'),
                      
                      // 중앙 영역: 필드 + 덱 더미
                      if (isGameStarted)
                        Expanded(child: _buildFieldWithDeck(gameState)),
                      
                      // 하단 영역: 내 획득 카드 + 점수 + 내 핸드
                      if (isGameStarted) _buildCapturedArea(gameState.playerCaptured, '내 획득'),
                      if (isGameStarted) _buildPlayerHand(gameState),
                    ],
                  ),
                ),
                if (isGameStarted && _showSidePanel)
                  _buildSidePanel(gameState, events),
              ],
            ),
          ),

          // 날아가는 카드 오버레이
          if (_flyingCards.isNotEmpty)
            CardAnimationOverlay(
              flyingCards: _flyingCards,
              onAllComplete: () {
                if (mounted) setState(() => _flyingCards = []);
              },
            ),

          if (!isGameStarted && !gameState.isFinished)
            _buildStartOverlay(strings),

          // 같은 월 2장 이상 선택 오버레이
          if (_selectableFieldCards.isNotEmpty)
            _buildCardSelectOverlay(),

          if (isGoStopPending)
            _buildGoStopOverlay(strings),

          // AI 고/스톱 화면 중앙 애니메이션
          if (aiGoStopAnnounce != null)
            _buildAiGoStopAnimation(aiGoStopAnnounce),

          // 족보 달성 알림 (#4)
          if (ref.watch(yakuAnnounceProvider) != null)
            _buildYakuAnnounce(ref.watch(yakuAnnounceProvider)!),

          if (gameState.isFinished)
            _buildRoundEndOverlay(gameState, strings),

          // 설정 오버레이
          if (_showSettings)
            SettingsOverlay(onClose: () => setState(() => _showSettings = false)),

          // 상점 오버레이 (#5)
          if (_showShop)
            ShopScreen(onClose: () => setState(() => _showShop = false)),

          // 튜토리얼 오버레이
          if (_showTutorial)
            TutorialOverlay(onComplete: () => setState(() => _showTutorial = false)),
        ],
      ),
    );
  }

  // ─── 배경 (스테이지별 고퀄 이미지) ────────────
  Widget _buildDynamicBackground(int score) {
    final run = ref.watch(runStateNotifierProvider);
    final stageConfig = getStageConfig(run.stage);
    return Stack(
      children: [
        // 고퀄 배경 이미지
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/${stageConfig.bgFile}',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [stageConfig.matColor, stageConfig.matColor.withValues(alpha: 0.8)],
                ),
              ),
            ),
          ),
        ),
        // 가벼운 비네트 (가장자리만 살짝)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── 시작 오버레이 (프리미엄 디자인) ─────────────
  Widget _buildStartOverlay(dynamic strings) {
    const brightIds = ['m01_bright', 'm03_bright', 'm08_bright', 'm11_bright', 'm12_bright'];
    const fanAngle = 0.18;
    final run = ref.watch(runStateNotifierProvider);
    final stageConfig = getStageConfig(run.stage);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    final currency = getCurrencyForLocale(run.currencyLocale);
    
    // 상대 자금이 0이면 표시용 값은 즉시 계산 (상태 변경은 didChangeDependencies에서)
    var displayOpponentMoney = run.opponentMoney;
    if (displayOpponentMoney <= 0) {
      displayOpponentMoney = getOpponentFund(run.stage, run.currentOpponentIndex, currency.pointValue);
    }
    
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0D0D0D)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 5광 부채살 + 글로우
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.15), blurRadius: 60, spreadRadius: 20)],
                  ),
                  child: SizedBox(
                    width: 320, height: 180,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        for (var i = 0; i < brightIds.length; i++)
                          Positioned(
                            bottom: 0,
                            child: Transform.rotate(
                              angle: (i - 2) * fanAngle,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 80, height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                                  boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.25), blurRadius: 12)],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                    'assets/images/cards/${brightIds[i]}.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFF2A1A3A),
                                      child: Center(child: Text('${i + 1}광', style: const TextStyle(color: Colors.white))),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
                  ).createShader(bounds),
                  child: const Text(
                    'K-Poker',
                    style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 6),
                  ),
                ),
                const SizedBox(height: 4),
                Text('화투 타짜의 도박', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16, letterSpacing: 4, fontWeight: FontWeight.w300)),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Text('${stageConfig.emoji} ${stageConfig.nameKo}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('${ai.emoji} ${ai.nameKo}', 
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('상대 자금: ${currency.formatAmount(displayOpponentMoney)}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                    boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: _startGameWithDeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 2),
                    ),
                    child: Text(strings.startGame),
                  ),
                ),
                const SizedBox(height: 16),
                Text('💰 ${currency.formatAmount(run.money)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16, right: 16,
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _showTutorial = true),
                  icon: const Text('❓', style: TextStyle(fontSize: 20)),
                  tooltip: '도움말',
                ),
                IconButton(
                  onPressed: () => setState(() => _showSettings = true),
                  icon: const Text('⚙️', style: TextStyle(fontSize: 20)),
                  tooltip: '설정',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── 상단 바 (왼쪽: AI 캐릭터, 오른쪽: 이번 판 점수) ─────────
  Widget _buildTopBar(dynamic state, dynamic strings) {
    final run = ref.watch(runStateNotifierProvider);
    final stageConfig = getStageConfig(run.stage);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ◀ 왼쪽: AI 캐릭터 아바타 + 이름 + 상대 소지금
          Row(
            children: [
              // AI 아바타
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/characters/${ai.avatarFile}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF2A1A3A),
                      child: Center(child: Text(ai.emoji, style: const TextStyle(fontSize: 20))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ai.nameKo, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${stageConfig.emoji} ${stageConfig.nameKo}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('상대: ${state.opponentScore}점',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const Spacer(),
          // ▶ 오른쪽: 이번 판 점수 + 턴 표시 + 설정
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 턴 표시 + 설정
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: state.currentTurn == 'player'
                          ? Colors.blue.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      state.currentTurn == 'player' ? '🎯 내 턴' : '🤖 AI',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _showTutorial = true),
                    child: const Text('❓', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _showSettings = true),
                    child: const Text('⚙️', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 이번 판 점수
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _chipBox('${state.playerScore}점', Colors.blueAccent),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Text('×', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ),
                  _chipBox('${state.multiplier.toStringAsFixed(1)}배', Colors.redAccent),
                  if (state.goCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text('🔥Go×${state.goCount}',
                        style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 상대 캐릭터 정보 바 (이름 + 점수 + 말풍선 + 체력)
  Widget _buildOpponentInfoBar(dynamic state) {
    final run = ref.watch(runStateNotifierProvider);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    final events = ref.watch(gameEventsProvider);
    final currency = getCurrencyForLocale(run.currencyLocale);
    final stageConfig = getStageConfig(run.stage);
    
    // 상대 체력 계산 (목표 금액 - 내가 달성한 금액)
    final stake = stageConfig.getStake(currency.pointValue);
    final currentEarned = run.stageEarned;
    final oppMoneyLeft = (stake - currentEarned).clamp(0.0, double.infinity);
    final hpRatio = (oppMoneyLeft / stake).clamp(0.0, 1.0);
    
    // 최근 AI 대사 찾기
    String? latestDialogue;
    for (int i = events.length - 1; i >= 0 && i > events.length - 4; i--) {
      if (events[i].type == 'ai_talk') {
        latestDialogue = events[i].message.replaceAll(RegExp(r'^💬 .{1,2} '), '');
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // AI 캐릭터 이모지 + 이름
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ai.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(ai.nameKo, style: const TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 상대 점수
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${state.opponentScore}점',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              // 남아있는 적 판돈 (HP)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('남은 자금: ${currency.formatAmount(oppMoneyLeft)}', 
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: hpRatio,
                        backgroundColor: Colors.red.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          hpRatio > 0.5 ? Colors.redAccent : (hpRatio > 0.2 ? Colors.orange : Colors.yellow)
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // AI 말풍선 (아래로 분리)
          if (latestDialogue != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  latestDialogue,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── 상대 핸드 (카드 뒷면) ─────────
  Widget _buildOpponentHand(dynamic state) {
    final count = _isDealing ? _dealtOpponentCount : state.opponentHand.length;
    return SizedBox(
      height: _opponentHandHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count && i < state.opponentHand.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: HwatuCard(card: state.opponentHand[i], size: _opponentCardSize, isFaceDown: true,
                skinPath: ref.watch(cardSkinProvider).assetPath),
            ),
        ],
      ),
    );
  }

  // ─── 획득 카드 (부채형) ──────
  Widget _buildCapturedArea(List<CardInstance> captured, String label) {
    if (captured.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 11)),
      );
    }

    // 원본 리스트 복제 후 월(Month) 기준 오름차순 정렬
    final sortedCaptured = List<CardInstance>.from(captured)
      ..sort((a, b) => a.def.month.compareTo(b.def.month));

    final brights = sortedCaptured.where((c) => c.def.grade == CardGrade.bright).toList();
    final animals = sortedCaptured.where((c) => c.def.grade == CardGrade.animal).toList();
    final ribbons = sortedCaptured.where((c) => c.def.grade == CardGrade.ribbon).toList();
    final junks = sortedCaptured.where((c) => c.def.grade == CardGrade.junk).toList();

    return SizedBox(
      height: _capturedAreaHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$label ${captured.length}', style: const TextStyle(color: Colors.amber, fontSize: 10)),
            ),
            if (brights.isNotEmpty) _buildFanGroup(brights),
            if (animals.isNotEmpty) _buildFanGroup(animals),
            if (ribbons.isNotEmpty) _buildFanGroup(ribbons),
            if (junks.isNotEmpty) _buildFanGroup(junks),
          ],
        ),
      ),
    );
  }

  Widget _buildFanGroup(List<CardInstance> cards) {
    final cardSize = _capturedCardSize;
    const fanAngleStep = 0.12;
    final startAngle = -(cards.length - 1) * fanAngleStep / 2;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: cardSize + (cards.length - 1) * 14 + 8,
        height: _capturedFanHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < cards.length; i++)
              Positioned(
                left: i * 14.0,
                top: 0,
                child: Transform.rotate(
                  angle: startAngle + i * fanAngleStep,
                  child: HwatuCard(card: cards[i], size: cardSize),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── 필드 + 덱 더미 ───────────
  Widget _buildFieldWithDeck(dynamic state) {
    final deckCount = _isDealing ? _visibleDeckCount : state.deck.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _buildDeckPile(deckCount),
        ),
        Expanded(child: _buildFieldArea(state)),
      ],
    );
  }

  // ─── 덱 더미 (플레이어 카드 크기와 동일) ────
  Widget _buildDeckPile(int remaining) {
    final cardW = (72.0 * _scale).clamp(40, 80).toDouble();
    final cardH = (108.0 * _scale).clamp(60, 120).toDouble();

    return Column(
      children: [
        SizedBox(
          width: cardW + 6,
          height: cardH + 6,
          child: Stack(
            children: [
              if (remaining > 4)
                Positioned(left: 6, top: 6, child: _buildMiniBack(cardW - 4, cardH - 4)),
              if (remaining > 2)
                Positioned(left: 4, top: 4, child: _buildMiniBack(cardW - 2, cardH - 2)),
              if (remaining > 1)
                Positioned(left: 2, top: 2, child: _buildMiniBack(cardW - 1, cardH - 1)),
              if (remaining > 0)
                Positioned(left: 0, top: 0, child: _buildMiniBack(cardW, cardH)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$remaining', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildMiniBack(double w, double h) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.4), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          ref.watch(cardSkinProvider).assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF2A1A3A),
            child: const Center(child: Text('🎴', style: TextStyle(fontSize: 16))),
          ),
        ),
      ),
    );
  }

  // ─── 필드 영역 ────────────────
  Widget _buildFieldArea(dynamic state) {
    final count = _isDealing ? _dealtFieldCount : state.field.length;
    return Container(
      constraints: BoxConstraints(minHeight: _fieldMinHeight),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2), width: 1),
      ),
      child: count == 0
          ? const Center(child: Text('필드', style: TextStyle(color: Colors.white24, fontSize: 16)))
          : Wrap(
              spacing: 5, runSpacing: 5, alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < count && i < state.field.length; i++)
                  HwatuCard(card: state.field[i], size: _fieldCardSize, isField: true),
              ],
            ),
    );
  }


  Widget _chipBox(String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  // ─── 플레이어 핸드 (매칭 가능 카드 올라옴 + 폭탄 표시) ─────────────
  Widget _buildPlayerHand(dynamic state) {
    // 월 순서로 정렬 (같은 월이면 grade 순)
    final sortedHand = List<CardInstance>.from(state.playerHand)
      ..sort((a, b) {
        final monthCmp = a.def.month.compareTo(b.def.month);
        if (monthCmp != 0) return monthCmp;
        return a.def.grade.index.compareTo(b.def.grade.index);
      });
    final count = _isDealing ? _dealtPlayerCount : sortedHand.length;
    // 필드에 있는 월 목록
    final fieldMonths = <int>{};
    for (final fc in state.field) {
      fieldMonths.add(fc.def.month);
    }

    // 폭탄 감지: 같은 월 3장
    final bombMonth = GameEngine.getBombMonth(
      List<CardInstance>.from(state.playerHand),
    );

    return Container(
      height: _playerHandHeight,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 총통 버튼 (같은 월 4장 보유 시)
            if (!_isDealing && state.currentTurn == 'player')
              () {
                final chongtongMonth = ref.read(gameStateProvider.notifier).getPlayerChongtong();
                if (chongtongMonth == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 15),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(gameStateProvider.notifier).declareChongtong(chongtongMonth);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B00)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 12)],
                      ),
                      child: Text('🎆 총통 ${chongtongMonth}월',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                );
              }(),
            // 폭탄 버튼 (같은 월 3장 보유 시)
            if (bombMonth != null && !_isDealing && state.currentTurn == 'player')
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 15),
                child: GestureDetector(
                  onTap: () {
                    _executeBomb(bombMonth);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 12)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💣', style: TextStyle(fontSize: 24)),
                        Text('${bombMonth}월', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        const Text('폭탄!', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            for (var i = 0; i < count && i < sortedHand.length; i++)
              () {
                final card = sortedHand[i];
                final canMatch = fieldMonths.contains(card.def.month);
                final isBombCard = bombMonth != null && card.def.month == bombMonth;
                final isPlayable = !_isDealing && state.currentTurn == 'player';
                return Padding(
                  padding: EdgeInsets.only(
                    left: 3, right: 3,
                    bottom: isBombCard ? 20 : ((canMatch && isPlayable) ? 15 : 0),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      HwatuCard(
                        card: card,
                        size: _playerCardSize,
                        onTap: isPlayable
                            ? () => _playCardWithAnimation(card)
                            : null,
                      ),
                      // 폭탄 대상 카드에 💣 배지
                      if (isBombCard && isPlayable)
                        Positioned(
                          top: -8,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.6), blurRadius: 8)],
                            ),
                            child: const Text('💣', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                    ],
                  ),
                );
              }(),
          ],
        ),
      ),
    );
  }

  /// 카드 플레이 + 날아가는 애니메이션 + 매칭 선택
  void _playCardWithAnimation(CardInstance card) {
    final state = ref.read(gameStateProvider);
    // 같은 월 카드가 필드에 2장 이상이면 선택 UI 표시
    final sameMonthCards = state.field.where((f) => f.def.month == card.def.month).toList();
    
    if (sameMonthCards.length >= 2) {
      setState(() {
        _pendingPlayedCard = card;
        _selectableFieldCards = sameMonthCards;
      });
      return; // 선택 대기
    }

    _executePlay(card);
  }

  /// 순차 애니메이션 시퀀스로 카드 플레이
  void _executePlay(CardInstance card) async {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final random = Random();
    final state = ref.read(gameStateProvider);

    // 매칭 카드 위치 계산 (필드 중앙 영역)
    final fieldCenterX = screenW * 0.45;
    final fieldCenterY = screenH * 0.38;

    setState(() {
      _pendingPlayedCard = null;
      _selectableFieldCards = [];
    });

    // ── STEP 1: 내 카드 → 필드 매칭 카드로 던짐 ──
    setState(() {
      _flyingCards = [
        FlyingCard(
          card: card,
          from: Offset(screenW * 0.35, screenH - 140),
          to: Offset(fieldCenterX, fieldCenterY),
          startAngle: -0.15 + random.nextDouble() * 0.1,
          endAngle: 0.12 + random.nextDouble() * 0.08, // 기울어져 착지
          duration: const Duration(milliseconds: 350),
          size: 55,
        ),
      ];
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // 게임 로직 실행
    ref.read(gameStateProvider.notifier).playCard(card);

    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // ── STEP 2: 덱에서 카드 뒤집기 → 필드로 던짐 ──
    final updatedState = ref.read(gameStateProvider);
    if (updatedState.deck.isNotEmpty) {
      setState(() {
        _flyingCards = [
          FlyingCard(
            card: updatedState.deck.isNotEmpty ? updatedState.deck.first : card,
            from: const Offset(50, 280),  // 덱 위치
            to: Offset(fieldCenterX + 40, fieldCenterY + 10),
            startAngle: 0.1,
            endAngle: -0.1 + random.nextDouble() * 0.08,
            duration: const Duration(milliseconds: 350),
            size: 50,
          ),
        ];
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }

    // ── STEP 3: 획득 카드 한 장씩 내 영역으로 ──
    final afterState = ref.read(gameStateProvider);
    final newCaptured = afterState.playerCaptured.length - state.playerCaptured.length;
    
    if (newCaptured > 0) {
      for (var i = 0; i < newCaptured && i < 4; i++) {
        if (!mounted) return;
        setState(() {
          _flyingCards = [
            FlyingCard(
              card: afterState.playerCaptured[afterState.playerCaptured.length - newCaptured + i],
              from: Offset(fieldCenterX + (i * 15), fieldCenterY),
              to: Offset(screenW * 0.3 + (i * 25), screenH - 200), // 내 획득 영역
              startAngle: 0.05,
              endAngle: 0.0,
              duration: const Duration(milliseconds: 250),
              size: 40,
            ),
          ];
        });
        await Future.delayed(const Duration(milliseconds: 200)); // 착착착 한 장씩
      }
    }

    // 애니메이션 정리
    if (mounted) {
      setState(() => _flyingCards = []);
    }

    // AI 턴 감지 → 애니메이션 처리
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final stateAfterPlay = ref.read(gameStateProvider);
    if (stateAfterPlay.currentTurn == 'opponent' && !stateAfterPlay.isFinished) {
      await _executeAiTurn();
    }
  }

  /// AI 턴: 카드 선택 → 애니메이션 → playAiCard
  Future<void> _executeAiTurn() async {
    if (!mounted) return;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final random = Random();

    // AI가 카드 선택
    final aiCard = ref.read(gameStateProvider.notifier).getAiChoice();
    if (aiCard == null) {
      // AI 핸드가 비었거나 폭탄 → 안전하게 처리
      final opHand = ref.read(gameStateProvider).opponentHand;
      if (opHand.isEmpty) {
        // 핸드가 비면 나가리 — providers에서 이미 처리됨
        return;
      }
      // 폭탄 등 기존 로직으로 fallback
      ref.read(gameStateProvider.notifier).playAiCard(opHand.first);
      return;
    }

    final prevState = ref.read(gameStateProvider);
    final fieldCenterX = screenW * 0.45;
    final fieldCenterY = screenH * 0.38;

    // ── STEP 1: AI 카드 → 필드로 던짐 ──
    setState(() {
      _flyingCards = [
        FlyingCard(
          card: aiCard,
          from: Offset(screenW * 0.45, 30),  // 상대 핸드 영역 (상단)
          to: Offset(fieldCenterX, fieldCenterY),
          startAngle: 0.1 + random.nextDouble() * 0.1,
          endAngle: -0.08 + random.nextDouble() * 0.06,
          duration: const Duration(milliseconds: 400),
          size: 55,
        ),
      ];
    });

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    // 게임 로직 실행
    ref.read(gameStateProvider.notifier).playAiCard(aiCard);

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // ── STEP 2: 덱에서 카드 뒤집기 → 필드 ──
    final updatedState = ref.read(gameStateProvider);
    if (updatedState.deck.isNotEmpty) {
      setState(() {
        _flyingCards = [
          FlyingCard(
            card: updatedState.deck.isNotEmpty ? updatedState.deck.first : aiCard,
            from: const Offset(50, 280),
            to: Offset(fieldCenterX + 40, fieldCenterY + 10),
            startAngle: 0.1,
            endAngle: -0.1 + random.nextDouble() * 0.08,
            duration: const Duration(milliseconds: 350),
            size: 50,
          ),
        ];
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }

    // ── STEP 3: 획득 카드 → 상대 영역으로 순차 이동 ──
    final afterState = ref.read(gameStateProvider);
    final newCaptured = afterState.opponentCaptured.length - prevState.opponentCaptured.length;

    if (newCaptured > 0) {
      for (var i = 0; i < newCaptured && i < 4; i++) {
        if (!mounted) return;
        setState(() {
          _flyingCards = [
            FlyingCard(
              card: afterState.opponentCaptured[afterState.opponentCaptured.length - newCaptured + i],
              from: Offset(fieldCenterX + (i * 15), fieldCenterY),
              to: Offset(screenW * 0.3 + (i * 25), 90),  // 상대 획득 영역 (상단)
              startAngle: 0.05,
              endAngle: 0.0,
              duration: const Duration(milliseconds: 250),
              size: 40,
            ),
          ];
        });
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    if (mounted) {
      setState(() => _flyingCards = []);
    }
  }

  /// 폭탄 애니메이션: 3장 동시 날아가기 + 폭발 이펙트
  void _executeBomb(int bombMonth) async {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final random = Random();
    final state = ref.read(gameStateProvider);

    final fieldCenterX = screenW * 0.45;
    final fieldCenterY = screenH * 0.38;

    // 같은 월 3장 찾기
    final bombCards = state.playerHand
        .where((c) => c.def.month == bombMonth)
        .take(3)
        .toList();

    if (bombCards.length < 3) return;

    // ── STEP 1: 3장 동시에 필드로 날아감 (부채꼴) ──
    setState(() {
      _flyingCards = [
        for (var i = 0; i < bombCards.length; i++)
          FlyingCard(
            card: bombCards[i],
            from: Offset(screenW * (0.25 + i * 0.12), screenH - 140),
            to: Offset(
              fieldCenterX + (i - 1) * 40.0,
              fieldCenterY + (i - 1).abs() * 15.0,
            ),
            startAngle: -0.2 + i * 0.15,
            endAngle: -0.1 + random.nextDouble() * 0.2,
            duration: const Duration(milliseconds: 300),
            size: 55,
          ),
      ];
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    // ── STEP 2: 폭발 이펙트 (💥 표시) ──
    setState(() {
      _flyingCards = [
        FlyingCard(
          card: bombCards[0], // 아무 카드나 (이펙트용)
          from: Offset(fieldCenterX, fieldCenterY),
          to: Offset(fieldCenterX, fieldCenterY),
          startAngle: 0,
          endAngle: 0,
          duration: const Duration(milliseconds: 200),
          size: 80,
        ),
      ];
    });

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    // 게임 로직 실행
    ref.read(gameStateProvider.notifier).playBomb(bombMonth);

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // ── STEP 3: 획득 카드들 내 영역으로 ──
    final afterState = ref.read(gameStateProvider);
    final newCaptured = afterState.playerCaptured.length - state.playerCaptured.length;

    if (newCaptured > 0) {
      for (var i = 0; i < newCaptured && i < 6; i++) {
        if (!mounted) return;
        setState(() {
          _flyingCards = [
            FlyingCard(
              card: afterState.playerCaptured[afterState.playerCaptured.length - newCaptured + i],
              from: Offset(fieldCenterX, fieldCenterY),
              to: Offset(screenW * 0.5, screenH * 0.68),
              startAngle: 0.1 * i,
              endAngle: 0,
              duration: const Duration(milliseconds: 250),
              size: 40,
            ),
          ];
        });
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }

    // 애니메이션 정리
    if (mounted) {
      setState(() => _flyingCards = []);
    }
  }

  // ─── 사이드 패널 ─────────────
  Widget _buildSidePanel(dynamic state, List<GameEvent> events) {
    final run = ref.watch(runStateNotifierProvider);
    final currency = getCurrencyForLocale(run.currencyLocale);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          // 내 정보 요약 블록
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blueAccent.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('👤 My Info', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                    if (run.winStreak > 0)
                      Text('🔥${run.winStreak}연승', style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('💰 ${currency.formatAmount(run.money)}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('현재 점수', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                    Text('${state.playerScore}점 × ${state.multiplier.toStringAsFixed(1)}배', style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF30363D), height: 1),
          // 족보 달성 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: _buildYakuProgress(state),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(6),
              itemCount: events.length,
              itemBuilder: (_, i) {
                final event = events[events.length - 1 - i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: _eventColor(event.type).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.message,
                      style: TextStyle(color: _eventColor(event.type), fontSize: 11),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Color _eventColor(String type) {
    switch (type) {
      case 'match': return Colors.greenAccent;
      case 'miss': return Colors.grey;
      case 'go': return Colors.orangeAccent;
      case 'stop': return Colors.redAccent;
      case 'ai_play': return Colors.cyanAccent;
      case 'round_end': return Colors.yellowAccent;
      default: return Colors.white70;
    }
  }

  // ─── 고/스톱 오버레이 ─────────

  // ─── 카드 선택 오버레이 (같은 월 2장) ─────
  Widget _buildCardSelectOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan.withValues(alpha: 0.6), width: 2),
            boxShadow: [BoxShadow(color: Colors.cyan.withValues(alpha: 0.3), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎯 먹을 카드를 선택하세요', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('같은 월 카드가 ${_selectableFieldCards.length}장 있습니다', style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var fc in _selectableFieldCards)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () {
                          // 선택된 카드로 플레이
                          if (_pendingPlayedCard != null) {
                            _executePlay(_pendingPlayedCard!);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.cyan, width: 2),
                            boxShadow: [BoxShadow(color: Colors.cyan.withValues(alpha: 0.4), blurRadius: 12)],
                          ),
                          child: HwatuCard(card: fc, size: 90),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() {
                  _pendingPlayedCard = null;
                  _selectableFieldCards = [];
                }),
                child: const Text('취소', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// #4 족보 달성 알림 (화면 중앙 황금 플래시)
  Widget _buildYakuAnnounce(String yaku) {
    // 족보별 이모지 매핑
    const yakuEmoji = {
      '오광': '🌟', '사광': '⭐', '삼광': '✨', '비삼광': '🌧️',
      '홍단': '🔴', '청단': '🔵', '초단': '🟢',
      '고도리': '🐦', '오끗': '🦌',
      '쓸': '🌊',
    };

    final emoji = yakuEmoji[yaku] ?? '🎴';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return IgnorePointer(
          child: Center(
            child: Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x99000000), Color(0xBB1A1A2E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD700), width: 3),
                  boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 40, spreadRadius: 8)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 50)),
                    const SizedBox(height: 8),
                    Text(yaku, style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(color: Color(0xFFFFD700), blurRadius: 20),
                        Shadow(color: Colors.black, blurRadius: 6),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// #7 족보 진행도 (사이드 패널 하단용)
  Widget _buildYakuProgress(dynamic state) {
    final captured = state.playerCaptured as List<CardInstance>;
    final brights = captured.where((c) => c.def.grade == CardGrade.bright).length;
    final animals = captured.where((c) => c.def.grade == CardGrade.animal).length;
    final redRibbons = captured.where((c) => c.def.ribbonType == RibbonType.red).length;
    final blueRibbons = captured.where((c) => c.def.ribbonType == RibbonType.blue).length;
    final grassRibbons = captured.where((c) => c.def.ribbonType == RibbonType.grass).length;
    final junks = captured.where((c) => c.def.grade == CardGrade.junk).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📊 족보', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        _yakuBar('⭐ 광', brights, 3, Colors.amber),
        _yakuBar('🔴 홍단', redRibbons, 3, Colors.red),
        _yakuBar('🔵 청단', blueRibbons, 3, Colors.blue),
        _yakuBar('🟢 초단', grassRibbons, 3, Colors.green),
        _yakuBar('🦌 열끗', animals, 5, Colors.cyan),
        _yakuBar('🃏 피', junks, 10, Colors.grey),
      ],
    );
  }

  Widget _yakuBar(String name, int current, int target, Color color) {
    final ratio = (current / target).clamp(0.0, 1.0);
    final isComplete = current >= target;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(name, style: TextStyle(
            color: isComplete ? color : Colors.white54, fontSize: 10,
            fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
          ))),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: isComplete ? color : color.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 30, child: Text('$current/$target', textAlign: TextAlign.right,
            style: TextStyle(color: isComplete ? color : Colors.white38, fontSize: 9))),
        ],
      ),
    );
  }

  // ─── 고/스톱 오버레이 (기존) ─────────
  /// AI 고/스톱 화면 중앙 빨간 글자 애니메이션
  Widget _buildAiGoStopAnimation(String announce) {
    final isStop = announce == 'stop';
    final goCount = isStop ? 0 : int.tryParse(announce.replaceAll('go_', '')) ?? 1;

    final emoji = isStop ? '🛑' : '🔥';
    final text = isStop ? '스톱!' : '고! ×$goCount';
    final color = isStop ? Colors.white : const Color(0xFFFF2200);
    final bgColor = isStop
        ? Colors.blueGrey.withValues(alpha: 0.8)
        : Colors.red.withValues(alpha: 0.3);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.4 * value),
          child: Center(
            child: Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isStop ? Colors.white : const Color(0xFFFF4500),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isStop ? Colors.white : Colors.red).withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🤖 AI', style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 8),
                    Text(emoji, style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 12),
                    Text(text, style: TextStyle(
                      color: color,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(color: color.withValues(alpha: 0.8), blurRadius: 20),
                        Shadow(color: color.withValues(alpha: 0.5), blurRadius: 40),
                        const Shadow(color: Colors.black, blurRadius: 6),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoStopOverlay(dynamic strings) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text('3점 달성!', style: TextStyle(color: Color(0xFFFFD700), fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('고를 외치면 배율이 2배!\n하지만 지면 2배로 잃는다...', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => ref.read(gameStateProvider.notifier).declareGo(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(strings.goDecision, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => ref.read(gameStateProvider.notifier).declareStop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(strings.stopDecision, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 라운드 종료 오버레이 (개선) ──────
  Widget _buildRoundEndOverlay(dynamic state, dynamic strings) {
    final isWin = state.playerScore > state.opponentScore;
    final run = ref.watch(runStateNotifierProvider);
    final currency = getCurrencyForLocale(run.currencyLocale);
    final isBankrupt = !isWin && ref.read(runStateNotifierProvider.notifier).isBankrupt;
    
    // 족보 분석
    final pBright = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.bright).length;
    final pAnimal = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.animal).length;
    final pRibbon = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.ribbon).length;
    final pJunk = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.junk).length;

    // 수입 계산 (game_providers._handleRoundEnd와 동일)
    // 공식: 점수(baseChips) × 판돈 단위(pointValue) × 배율(multiplier)
    final baseScore = state.baseChips;
    final mult = state.multiplier;
    final earnings = isWin
        ? baseScore * currency.pointValue * mult
        : -(state.opponentScore > 0 ? state.opponentScore : 1) * currency.pointValue;

    // ── 파산 시 게임오버 화면 ──
    if (isBankrupt) {
      return Container(
        color: Colors.black.withValues(alpha: 0.92),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: _screenW * 0.85 > 380 ? 380 : _screenW * 0.85),
            padding: EdgeInsets.all(_scale > 0.7 ? 28 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.redAccent, width: 3),
              boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 5)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💸', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                const Text('파산!', style: TextStyle(
                  color: Colors.redAccent, fontSize: 36, fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.red, blurRadius: 20)],
                )),
                const SizedBox(height: 8),
                const Text('소지금이 바닥났습니다...', style: TextStyle(color: Colors.white54, fontSize: 16)),
                const SizedBox(height: 20),

                // 최종 성적
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      _gameOverStatRow('🏆 총 승리', '${run.wins}승'),
                      _gameOverStatRow('💀 총 패배', '${run.losses}패'),
                      _gameOverStatRow('🔥 최고 연승', '${run.winStreak}연승'),
                      _gameOverStatRow('⭐ 최고 점수', '${run.highestScore}점'),
                      _gameOverStatRow('💰 최고 소지금', currency.formatExact(run.highestMoney)),
                      _gameOverStatRow('📍 도달 스테이지', '스테이지 ${run.stage}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 재시작 버튼
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(runStateNotifierProvider.notifier).restartRun();
                    _startGameWithDeal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('🔄 처음부터 다시', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── 일반 라운드 종료 화면 ──
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: _screenW * 0.85 > 380 ? 380 : _screenW * 0.85),
          padding: EdgeInsets.all(_scale > 0.7 ? 28 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isWin ? const Color(0xFFFFD700) : Colors.redAccent, width: 2),
            boxShadow: [BoxShadow(color: (isWin ? Colors.amber : Colors.red).withValues(alpha: 0.3), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isWin ? '🏆' : '💀', style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(isWin ? '승리!' : '패배...',
                style: TextStyle(color: isWin ? const Color(0xFFFFD700) : Colors.redAccent, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // 족보 상세
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _resultBadge('🌟', '$pBright', '광'),
                    _resultBadge('🐾', '$pAnimal', '동물'),
                    _resultBadge('🎀', '$pRibbon', '띠'),
                    _resultBadge('🍂', '$pJunk', '피'),
                    if (state.sweepCount > 0)
                      _resultBadge('🧹', '${state.sweepCount}', '쓸'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 수입 계산 과정
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('점수', style: TextStyle(color: Colors.white54, fontSize: 13)),
                        Text('${state.playerScore} vs ${state.opponentScore}',
                          style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                    if (isWin) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('계산', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          Text('${state.baseChips.toInt()}점 × ${currency.formatAmount(currency.pointValue)}'
                            '${mult > 1.0 ? ' × ${mult.toStringAsFixed(1)}' : ''}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                    const Divider(color: Color(0xFF30363D), height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isWin ? '💰 수입' : '💸 손실',
                          style: TextStyle(color: isWin ? Colors.greenAccent : Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(isWin ? '+${currency.formatAmount(earnings)}' : currency.formatAmount(earnings),
                          style: TextStyle(color: isWin ? Colors.greenAccent : Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              if (state.goCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('🔥 Go ×${state.goCount}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 16)),
                ),
              const SizedBox(height: 16),

              // 버튼: 상점/다음 라운드
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isWin)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showShop = true;
                        });
                      },
                      icon: const Text('🛒'),
                      label: const Text('상점'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Color(0xFF30363D)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _startGameWithDeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(isWin ? '다음 라운드 →' : '재도전!',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameOverStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _resultBadge(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

class _DealTarget {
  final String area; // 'field', 'opponent', 'player'
  final int index;
  _DealTarget(this.area, this.index);
}

/// 화투판 바닥 패턴 페인터 (스테이지별 다른 질감)
class _HwatuMatPainter extends CustomPainter {
  final Color baseColor;
  final Color accentColor;
  final int stage;

  _HwatuMatPainter({
    required this.baseColor,
    required this.accentColor,
    required this.stage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 바닥 기본 색상
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = baseColor,
    );

    // 2. 스테이지별 패턴
    final accentPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final spacing = stage <= 2 ? 28.0 : (stage <= 4 ? 36.0 : 44.0);

    // 격자 무늬 (돗자리/펠트/다다미 느낌)
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        accentPaint,
      );
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        accentPaint,
      );
    }

    // 3. 테두리 장식 (화투판 가장자리)
    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(16),
    );
    canvas.drawRRect(borderRect, borderPaint);

    // 4. 미세한 그라데이션 질감 (중앙이 약간 밝게)
    final centerGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          baseColor.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), centerGlow);
  }

  @override
  bool shouldRepaint(_HwatuMatPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.stage != stage;
  }
}
