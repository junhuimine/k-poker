/// 🎴 K-Poker — 메인 게임 화면 (애니메이션 버전)
///
/// 딜링, 카드 던짐, 획득 날아오기 등 전체 카드 모션 시스템 포함
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_providers.dart';
import '../state/card_skin_provider.dart';
import '../engine/game_engine.dart';
import '../state/audio_manager.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_provider.dart';
import '../engine/card_matcher.dart';
import '../models/card_def.dart';
import '../data/all_cards.dart';
import '../data/stage_config.dart';
import '../data/item_catalog.dart';
import 'widgets/hwatu_card.dart';
import 'widgets/card_animation_overlay.dart';
import 'settings_overlay.dart';
import 'tutorial_overlay.dart';
import 'shop_screen.dart';
import 'widgets/side_panel.dart';
import 'widgets/game_overlays.dart';
import 'widgets/special_event_effect.dart';
import '../state/tutorial_provider.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/tutorial_popup_overlay.dart';
import '../common/responsive.dart';
import '../services/ad_service.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  // 스플래시/로딩 상태
  bool _isLoading = true;
  double _splashOpacity = 1.0;

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

  // 필드 카드의 동적 렌더링 위치(RenderBox) 추적용 키 맵
  final Map<CardInstance, GlobalKey> _fieldCardKeys = {};

  // 획득 영역 등급별 그룹 위치 추적용 GlobalKey (플레이어)
  final GlobalKey _capturedBrightKey = GlobalKey();
  final GlobalKey _capturedAnimalKey = GlobalKey();
  final GlobalKey _capturedRibbonKey = GlobalKey();
  final GlobalKey _capturedJunkKey = GlobalKey();

  // 획득 영역 등급별 그룹 위치 추적용 GlobalKey (상대)
  final GlobalKey _opCapturedBrightKey = GlobalKey();
  final GlobalKey _opCapturedAnimalKey = GlobalKey();
  final GlobalKey _opCapturedRibbonKey = GlobalKey();
  final GlobalKey _opCapturedJunkKey = GlobalKey();

  // 설정/튜토리얼 오버레이
  bool _showSettings = false;
  bool _showShop = false;
  bool _showTutorial = false;

  // ─── 반응형 UI 헬퍼 (화면 비율 기반) ─────────────────
  double get _screenW => Responsive.screenWidth(context);
  double get _screenH => Responsive.screenHeight(context);
  double get _scale => Responsive.scale(context);
  double get _scaleH => Responsive.scaleY(context);
  
  bool _isPanelExpanded = false;
  // 모바일 가로 모드 (화면 폭 900 미만)에서는 사이드 패널을 기본으로 숨기고 토글형으로.
  bool get _shouldShowPanel => _screenW >= 900 ? true : _isPanelExpanded;

  // 카드 크기 (화면 비율에 따라 부드럽게 스케일, 터치 영역 확보를 위해 여유있게)
  double get _opponentCardSize => (42 * _scale).clamp(16, 55);
  double get _fieldCardSize => (76 * _scale).clamp(24, 100);
  double get _playerCardSize => (82 * _scale).clamp(28, 105);
  double get _capturedCardSize => (50 * _scale).clamp(14, 60);
  double get _capturedFanHeight => (75 * _scale).clamp(20, 90);

  // 레이아웃 수치 (화면 비율 기반)
  double get _opponentHandHeight => (75 * _scaleH).clamp(20, 90);
  double get _playerHandHeight => (155 * _scaleH).clamp(50, 180);
  double get _capturedAreaHeight => (80 * _scaleH).clamp(24, 95);
  double get _fieldMinHeight => (150 * _scaleH).clamp(40, 180);
  // ignore: unused_element
  double get _fontSize => (13 * _scale).clamp(11, 18);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 앱 시작 시 저장된 게임 자동 불러오기 + 에셋 프리캐시
    if (!_loadAttempted) {
      _loadAttempted = true;
      ref.read(runStateNotifierProvider.notifier).loadGame().then((_) {
        // 로드 후 상대 자금 보정
        ref.read(runStateNotifierProvider.notifier).fixOpponentMoney();
      });
      _precacheAssets();
    }
  }

  bool _loadAttempted = false;

  /// 주요 카드 이미지를 프리캐시하고 스플래시를 페이드아웃
  Future<void> _precacheAssets() async {
    // 5광 + 카드 뒷면 등 핵심 이미지 프리캐시
    final importantAssets = [
      'assets/images/cards/card_back.webp',
      'assets/images/cards/m01_bright.webp',
      'assets/images/cards/m03_bright.webp',
      'assets/images/cards/m08_bright.webp',
      'assets/images/cards/m11_bright.webp',
      'assets/images/cards/m12_bright.webp',
      // 배경 이미지 (깜빡임 방지)
      'assets/images/backgrounds/bg_stage1.png',
      'assets/images/backgrounds/bg_stage2.png',
      'assets/images/backgrounds/bg_stage3.png',
      'assets/images/backgrounds/bg_stage4.png',
      'assets/images/backgrounds/bg_stage5.png',
      'assets/images/backgrounds/bg_stage6.png',
    ];

    final futures = importantAssets.map((path) async {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {
        // 이미지 로드 실패 시 무시 (errorBuilder가 대응)
      }
    }).toList();

    // 프리캐시 타임아웃: 5초 넘으면 포기하고 진행 (로딩 멈춤 방지)
    await Future.wait(futures).timeout(
      const Duration(seconds: 5),
      onTimeout: () => <Null>[],
    );

    // 최소 표시 시간 보장
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // 페이드아웃 트리거
      setState(() => _splashOpacity = 0.0);
      // 페이드아웃 애니메이션 완료 대기
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 게임 시작 + 딜링 애니메이션 (고스톱 3-4-3 그룹)
  void _startGameWithDeal() {
    ref.read(gameStateProvider.notifier).startGame(); // sync!
    AudioManager().startBgmLoop();
    final gameState = ref.read(gameStateProvider);

    setState(() {
      _isDealing = true;
      _dealtOpponentCount = 0;
      _dealtFieldCount = 0;
      _dealtPlayerCount = 0;
      _visibleDeckCount = totalCards;
      _flyingCards = [];
    });

    _runGroupDealSequence(gameState);
  }

  /// 고스톱 딜링: 3-4-3 그룹으로 날아감
  void _runGroupDealSequence(dynamic gameState) async {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final deckPos = Offset(30, screenH * 0.4);
    final random = Random();

    final dealGroups = <(String, int)>[
      ('opponent', 3), ('field', 4), ('player', 3),
      ('opponent', 3), ('field', 4), ('player', 3),
      ('opponent', 4), ('player', 4),
    ];

    await Future.delayed(const Duration(milliseconds: 200));

    for (final (area, count) in dealGroups) {
      if (!mounted) return;

      final startIdx = area == 'opponent' ? _dealtOpponentCount
          : area == 'field' ? _dealtFieldCount
          : _dealtPlayerCount;

      // 그룹 카드 날리기
      final List<FlyingCard> groupCards = [];
      for (int i = 0; i < count; i++) {
        final idx = startIdx + i;
        Offset to;
        CardInstance card;
        bool faceDown = false;

        switch (area) {
          case 'opponent':
            to = Offset(screenW * 0.3 + idx * 42, 60);
            card = gameState.opponentHand[idx];
            faceDown = true;
            break;
          case 'field':
            to = Offset(screenW * 0.25 + idx * 65, screenH * 0.35);
            card = gameState.field[idx];
            break;
          default:
            to = Offset(screenW * 0.2 + idx * 78, screenH - 150);
            card = gameState.playerHand[idx];
            break;
        }

        groupCards.add(FlyingCard(
          card: card,
          from: deckPos,
          to: to,
          startAngle: -0.2 + random.nextDouble() * 0.1,
          endAngle: (random.nextDouble() - 0.5) * 0.1,
          isFaceDown: faceDown,
          delay: Duration(milliseconds: i * 60),
          duration: const Duration(milliseconds: 350),
          size: faceDown ? 38 : (area == 'field' ? 50 : 72),
          style: 'deal',
        ));
      }

      // 날리기 시작
      setState(() {
        _visibleDeckCount -= count;
        _flyingCards = groupCards;
      });

      // 카드 착지 대기
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      // 카드 자리에 깔기
      setState(() {
        switch (area) {
          case 'opponent':
            _dealtOpponentCount += count;
            break;
          case 'field':
            _dealtFieldCount += count;
            break;
          case 'player':
            _dealtPlayerCount += count;
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
      // 흔들기 체크: 딜링 후 핸드에 같은 월 3장이면 선택 다이얼로그
      _checkShake();
      // 선(先)이 AI인 경우, 딜링 후 AI 턴 자동 실행
      final st = ref.read(gameStateProvider);
      if (st.currentTurn == 'opponent' && !st.isFinished) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) _executeAiTurn();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final strings = ref.watch(appStringsProvider);
    final isGoStopPending = ref.watch(goStopPendingProvider);
    final aiGoStopAnnounce = ref.watch(aiGoStopAnnounceProvider);
    final events = ref.watch(gameEventsProvider);

    // 튜토리얼 팝업 상태 체크
    final tutState = ref.watch(tutorialProvider);
    final isFirstYakuTutVisible = !tutState.isLoading && !tutState.suppressAllTutorials && !tutState.hasSeenFirstYaku && gameState.playerScore >= 1;
    final isFirstGoTutVisible = !tutState.isLoading && !tutState.suppressAllTutorials && !tutState.hasSeenFirstGo && gameState.goCount >= 1;

    final isGameStarted = gameState.deck.isNotEmpty || gameState.isFinished || _isDealing;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double minWidth = 800.0;
        const double minHeight = 400.0;
        final bool needScale = constraints.maxWidth < minWidth || constraints.maxHeight < minHeight;
        
        final logicalWidth = max(minWidth, constraints.maxWidth);
        final logicalHeight = max(minHeight, constraints.maxHeight);

        Widget content = MediaQuery(
          data: MediaQuery.of(context).copyWith(size: Size(logicalWidth, logicalHeight)),
          child: SizedBox(
            width: logicalWidth,
            height: logicalHeight,
            child: Scaffold(
              backgroundColor: const Color(0xFF0A0A0A),
              body: Stack(
                children: [
          _buildDynamicBackground(gameState.playerScore),

          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // 최상단 가로 배너 광고 (적 핸드 위)
                      if (isGameStarted) const AdBannerWidget(),
                      // 상단 영역: 통합 TopBar (캐릭터 / 상대 핸드 / 설정)
                      if (isGameStarted) _buildTopBar(gameState, strings),
                      if (isGameStarted) _buildCapturedArea(gameState.opponentCaptured, strings.opponentCapturedLabel, isPlayer: false),

                      // 중앙 영역: 덱 더미 + 필드
                      if (isGameStarted)
                        Expanded(child: _buildFieldWithDeck(gameState)),

                      // 하단 영역: 내 획득 카드 + 내 핸드
                      if (isGameStarted) _buildCapturedArea(gameState.playerCaptured, strings.playerCapturedLabel, isPlayer: true),
                      if (isGameStarted) _buildPlayerHand(gameState),
                    ],
                  ),
                ),
                if (isGameStarted && _shouldShowPanel)
                  GameSidePanel(state: gameState, events: events),
              ],
            ),
          ),

          // 우측 패널 토글 버튼 (화면이 작을 때만 표시)
          if (isGameStarted && _screenW < 900)
            Positioned(
              right: _shouldShowPanel ? 140 : 0, // 열렸을 땐 패널 너비만큼 이동
              top: _screenH * 0.4,
              child: GestureDetector(
                onTap: () => setState(() => _isPanelExpanded = !_isPanelExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Icon(
                    _shouldShowPanel ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20,
                  ),
                ),
              ),
            ),

          // 날아가는 카드 오버레이
          if (_flyingCards.isNotEmpty)
            CardAnimationOverlay(
              flyingCards: _flyingCards,
              onAllComplete: () {
                if (mounted) setState(() => _flyingCards = []);
              },
              strings: ref.watch(appStringsProvider),
            ),

          if (!isGameStarted && !gameState.isFinished)
            GameStartOverlay(
              strings: strings,
              onStart: _startGameWithDeal,
              onSettings: () => setState(() => _showSettings = true),
              onTutorial: () => setState(() => _showTutorial = true),
            ),

          // 같은 월 2장 이상 선택 오버레이
          if (_selectableFieldCards.isNotEmpty)
            CardSelectOverlay(
               selectableFieldCards: _selectableFieldCards,
               onSelect: (CardInstance fc) {
                 if (_pendingPlayedCard != null) {
                   _executePlay(_pendingPlayedCard!, targetFieldCard: fc);
                 }
               },
               onCancel: () {
                 setState(() {
                   _pendingPlayedCard = null;
                   _selectableFieldCards = [];
                 });
               },
               strings: strings,
            ),

          if (isGoStopPending)
            GoStopOverlay(
              strings: strings,
              onGo: () async {
                ref.read(gameStateProvider.notifier).declareGo();
                final st = ref.read(gameStateProvider);
                if (st.currentTurn == 'opponent' && !st.isFinished) {
                  await Future.delayed(const Duration(milliseconds: 1000));
                  if (mounted) _executeAiTurn();
                }
              },
              onStop: () => ref.read(gameStateProvider.notifier).declareStop(),
            ),

          // AI 고/스톱 화면 중앙 애니메이션
          if (aiGoStopAnnounce != null)
            AiGoStopAnimation(announce: aiGoStopAnnounce, strings: strings),

          // 족보 달성 알림 (#4)
          if (ref.watch(yakuAnnounceProvider) != null)
            SpecialEventEffect(
              key: ValueKey('effect_${ref.watch(yakuAnnounceProvider)}'),
              eventType: ref.watch(yakuAnnounceProvider)!,
              strings: strings,
            ),

          if (gameState.isFinished)
            Builder(builder: (context) {
              try {
                return RoundEndOverlay(
                  state: gameState,
                  strings: strings,
                  screenW: _screenW,
                  scale: _scale,
                  onNextRound: () {
                    _startGameWithDeal();
                  },
                  onShop: () {
                    final run = ref.read(runStateNotifierProvider);
                    ref.read(runStateNotifierProvider.notifier).openShop(run.stage);
                    setState(() => _showShop = true);
                  },
                  onRestart: () async {
                    await ref.read(runStateNotifierProvider.notifier).restartRun();
                    _startGameWithDeal();
                  },
                  onContinueWithAd: () async {
                    await AdService.showRewardedAd(
                      onRewarded: () {
                        ref.read(runStateNotifierProvider.notifier).reviveWithAd();
                        _startGameWithDeal();
                      },
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: Colors.red[800]),
                        );
                      },
                    );
                  },
                );
              } catch (e) {
                // RoundEndOverlay 렌더링 실패 시 안전한 대체 UI
                return Container(
                  color: Colors.black.withValues(alpha: 0.85),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(gameState.winner == 'player' ? '🏆 ${strings.ui('victory')}' : '💀 ${strings.ui('defeat')}',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                final run = ref.read(runStateNotifierProvider);
                                ref.read(runStateNotifierProvider.notifier).openShop(run.stage);
                                setState(() => _showShop = true);
                              },
                              icon: const Text('🛒'),
                              label: Text(strings.shop),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                _startGameWithDeal();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
                              child: Text(strings.ui('nextRound'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),

          // 설정 오버레이
          if (_showSettings)
            SettingsOverlay(onClose: () => setState(() => _showSettings = false)),

          // 상점 오버레이 (#5)
          if (_showShop)
            ShopScreen(onClose: () => setState(() => _showShop = false)),

          // ── 액티브 스킬 플로팅 버튼 ──
          if (!gameState.isFinished &&
              gameState.currentTurn == 'player' &&
              !isGoStopPending &&
              ref.watch(runStateNotifierProvider).inventorySkills.values.any((c) => c > 0))
            Positioned(
              right: 16,
              bottom: 150, // 플레이어 핸드 우측 상단
              child: FloatingActionButton.extended(
                heroTag: 'use_skill_fab',
                backgroundColor: Colors.blueAccent.withValues(alpha: 0.8),
                onPressed: () => _showSkillSelectDialog(context, ref),
                icon: const Icon(Icons.flash_on, color: Colors.amber),
                label: Text(strings.skillActivateBtn, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

          // 튜토리얼 오버레이
          if (_showTutorial)
            TutorialOverlay(onComplete: () => setState(() => _showTutorial = false)),

          // 실시간 규칙 안내 팝업 (가장 위)
          if (isFirstYakuTutVisible)
            TutorialPopupOverlay(
              title: strings.tutFirstYakuTitle,
              body: strings.tutFirstYakuBody,
              btnText: strings.continueBtn,
              doNotShowAgainText: strings.doNotShowAgain,
              onDismiss: (checked) {
                if (checked) {
                  ref.read(tutorialProvider.notifier).suppressAll();
                } else {
                  ref.read(tutorialProvider.notifier).markSeenFirstYaku();
                }
              },
            )
          else if (isFirstGoTutVisible)
            TutorialPopupOverlay(
              title: strings.tutFirstGoTitle,
              body: strings.tutFirstGoBody,
              btnText: strings.continueBtn,
              doNotShowAgainText: strings.doNotShowAgain,
              onDismiss: (checked) {
                if (checked) {
                  ref.read(tutorialProvider.notifier).suppressAll();
                } else {
                  ref.read(tutorialProvider.notifier).markSeenFirstGo();
                }
              },
            ),

          // 스플래시 로딩 오버레이 (최상단)
          if (_isLoading)
            AnimatedOpacity(
              opacity: _splashOpacity,
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A0A0A),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // K-Poker 로고 (골드 그라데이션)
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
                        ).createShader(bounds),
                        child: const Text(
                          'K-Poker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '화투 타짜',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 18,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FACFE)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
              ),
            ),
          ),
        );

        if (needScale) {
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: content,
            ),
          );
        }
        return content;
      },
    );
  }

  // ─── 배경 (스테이지별 고퀄 이미지) ────────────
  Widget _buildDynamicBackground(int score) {
    final run = ref.watch(runStateNotifierProvider);
    final stageConfig = getStageConfig(run.stage);
    return RepaintBoundary(child: Stack(
      children: [
        // 고퀄 배경 이미지
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/${stageConfig.bgFile}',
            fit: BoxFit.cover,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return Container(color: const Color(0xFF0A0A0A));
            },
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
    ));
  }

  // ─── 시작 오버레이 (프리미엄 디자인) ─────────────


  // ─── 상단 바 (왼쪽: AI 캐릭터, 중앙: 상대패, 오른쪽: 설정) ─────────
  Widget _buildTopBar(dynamic state, dynamic strings) {
    final run = ref.watch(runStateNotifierProvider);
    final stageConfig = getStageConfig(run.stage);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ◀ 왼쪽: AI 캐릭터 아바타 + 이름 (점수 삭제)
          Expanded(
            flex: 2,
            child: Row(
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
                    Text(strings.getAiName(ai), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('${stageConfig.emoji} ${strings.getStageName(stageConfig)}',
                      style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          
          // 🔼 중앙: 상대 핸드 (뒷면 여러 장)
          Expanded(
            flex: 4,
            child: _buildOpponentHand(state),
          ),
          // ▶ 오른쪽: 턴 표시 + 설정 (내 턴 점수 삭제)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                        state.currentTurn == 'player' ? strings.myTurnLabel : '🤖 AI',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 상대 캐릭터 정보 바 (이름 + 점수 + 말풍선 + 체력)


  // ─── 상대 핸드 (카드 뒷면, ps_bluff 시 일부 공개) ─────────
  Widget _buildOpponentHand(dynamic state) {
    final count = _isDealing ? _dealtOpponentCount : state.opponentHand.length;
    // ps_bluff (허세): 상대 패 첫 2장 공개
    final runState = ref.watch(runStateNotifierProvider);
    final revealCount = runState.ownedPassiveIds.contains('ps_bluff') ? 2 : 0;
    return SizedBox(
      height: _opponentHandHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count && i < state.opponentHand.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: HwatuCard(card: state.opponentHand[i], size: _opponentCardSize,
                isFaceDown: i >= revealCount, // 처음 revealCount장은 앞면
                skinPath: ref.watch(cardSkinProvider).assetPath,
                strings: ref.watch(appStringsProvider)),
            ),
        ],
      ),
    );
  }

  // ─── 획득 카드 (부채형) ──────
  Widget _buildCapturedArea(List<CardInstance> captured, String label, {bool isPlayer = false}) {
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
            // 플레이어/상대 모두 GlobalKey 부여 (애니메이션 도착 좌표용)
            if (brights.isNotEmpty) KeyedSubtree(
                key: isPlayer ? _capturedBrightKey : _opCapturedBrightKey,
                child: _buildFanGroup(brights)),
            if (animals.isNotEmpty) KeyedSubtree(
                key: isPlayer ? _capturedAnimalKey : _opCapturedAnimalKey,
                child: _buildFanGroup(animals)),
            if (ribbons.isNotEmpty) KeyedSubtree(
                key: isPlayer ? _capturedRibbonKey : _opCapturedRibbonKey,
                child: _buildFanGroup(ribbons)),
            if (junks.isNotEmpty) KeyedSubtree(
                key: isPlayer ? _capturedJunkKey : _opCapturedJunkKey,
                child: _buildFanGroup(junks)),
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
                  child: HwatuCard(card: cards[i], size: cardSize, strings: ref.watch(appStringsProvider)),
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

  // ─── 덱 더미 (플레이어 카드 크기와 동일, 남은 카드수 오버레이) ────
  Widget _buildDeckPile(int remaining) {
    final cardW = (72.0 * _scale).clamp(40, 80).toDouble();
    final cardH = (108.0 * _scale).clamp(60, 120).toDouble();

    return SizedBox(
      width: cardW + 6,
      height: cardH + 6,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (remaining > 4)
            Positioned(left: 6, top: 6, child: _buildMiniBack(cardW - 4, cardH - 4)),
          if (remaining > 2)
            Positioned(left: 4, top: 4, child: _buildMiniBack(cardW - 2, cardH - 2)),
          if (remaining > 1)
            Positioned(left: 2, top: 2, child: _buildMiniBack(cardW - 1, cardH - 1)),
          if (remaining > 0)
            Positioned(left: 0, top: 0, child: _buildMiniBack(cardW, cardH)),
            
          // 남은 카드수 표시를 텍스트로 합쳐서 카드 하단에 겹치게 배치
          Positioned(
            left: 0,
            right: 0,
            bottom: -5,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Text('$remaining', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
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
          ? Center(child: Text(ref.watch(appStringsProvider).fieldLabel, style: const TextStyle(color: Colors.white24, fontSize: 16)))
          : Wrap(
              spacing: 5, runSpacing: 5, alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < count && i < state.field.length; i++)
                  HwatuCard(
                    key: _fieldCardKeys[state.field[i]] ??= GlobalKey(),
                    card: state.field[i],
                    size: _fieldCardSize,
                    isField: true,

                    strings: ref.watch(appStringsProvider),
                  ),
              ],
            ),
    );
  }


  // ignore: unused_element
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

    // 폭탄 감지: 같은 월 3장 + 바닥에 같은 월 1장 이상 (복수 월 대응)
    final bombMonths = GameEngine.getBombMonths(
      List<CardInstance>.from(state.playerHand),
      List<CardInstance>.from(state.field),
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
                  padding: const EdgeInsets.only(right: 8, bottom: 4),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(gameStateProvider.notifier).declareChongtong(chongtongMonth);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B00)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 12)],
                      ),
                      child: Text(ref.watch(appStringsProvider).chongtongBtn(chongtongMonth),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                );
              }(),
            // 폭탄 버튼 (같은 월 3장 보유 시 — 복수 월이면 각각 버튼 표시)
            for (final bm in bombMonths)
              if (!_isDealing && state.currentTurn == 'player')
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 15),
                  child: GestureDetector(
                    onTap: () {
                      _executeBomb(bm);
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
                          Text(ref.watch(appStringsProvider).bombMonthLabel(bm), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text(ref.watch(appStringsProvider).bombLabel, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
            for (var i = 0; i < count && i < sortedHand.length; i++)
              () {
                final card = sortedHand[i];
                final canMatch = fieldMonths.contains(card.def.month);
                final isBombCard = bombMonths.contains(card.def.month);
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
    
                        strings: ref.watch(appStringsProvider),
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
  void _executePlay(CardInstance card, {CardInstance? targetFieldCard}) async {
    try {
      await _executePlayInner(card, targetFieldCard: targetFieldCard);
    } catch (e) {
      // 에러 발생 시 안전하게 상태 복구
      if (mounted) setState(() => _flyingCards = []);
    }
  }

  Future<void> _executePlayInner(CardInstance card, {CardInstance? targetFieldCard}) async {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final random = Random();
    final state = ref.read(gameStateProvider);

    // 매칭 카드 위치 계산 (기본 필드 중앙)
    double targetX = screenW * 0.45;
    double targetY = screenH * 0.38;

    // 타겟 카드 실제 화면 위치(RenderBox) 추적
    final matchable = findMatchableCards(card, state.field);
    if (matchable.isNotEmpty) {
      final actualTarget = targetFieldCard ?? matchable.first;
      final key = _fieldCardKeys[actualTarget];
      if (key != null && key.currentContext != null) {
        final box = key.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          targetX = position.dx;
          targetY = position.dy;
        }
      }
    }

    setState(() {
      _pendingPlayedCard = null;
      _selectableFieldCards = [];
    });

    // ── isDeckDraw 카드: 덱 뒤집기만 수행 (핸드 카드를 바닥에 내지 않음) ──
    if (card.isDeckDraw) {
      // 게임 로직 실행 (playTurn 내부에서 덱 뒤집기 + 매칭 처리)
      ref.read(gameStateProvider.notifier).playCard(card, selectedMatch: targetFieldCard);

      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      // 덱 뒤집기 애니메이션
      setState(() {
        _flyingCards = [
          FlyingCard(
            card: card,
            from: const Offset(50, 280),
            to: Offset(targetX, targetY),
            startAngle: 0.1,
            endAngle: -0.1 + random.nextDouble() * 0.08,
            duration: const Duration(milliseconds: 350),
            size: 50,
          ),
        ];
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    } else {
      // ── STEP 1: 내 카드 → 필드 매칭 카드로 던짐 ──
      setState(() {
        _flyingCards = [
          FlyingCard(
            card: card,
            from: Offset(screenW * 0.35, screenH - 140),
            to: Offset(targetX, targetY),
            startAngle: -0.15 + random.nextDouble() * 0.1,
            endAngle: 0.12 + random.nextDouble() * 0.08,
            duration: const Duration(milliseconds: 350),
            size: 55,
          ),
        ];
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      // 게임 로직 실행
      ref.read(gameStateProvider.notifier).playCard(card, selectedMatch: targetFieldCard);

      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      // ── STEP 2: 덱에서 카드 뒤집기 → 필드로 던짐 ──
      final updatedState = ref.read(gameStateProvider);
      if (updatedState.deck.isNotEmpty) {
        setState(() {
          _flyingCards = [
            FlyingCard(
              card: updatedState.deck.isNotEmpty ? updatedState.deck.first : card,
              from: const Offset(50, 280),
              to: Offset(targetX + 40, targetY + 10),
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
    }

    // ── STEP 3: 획득 카드 한 장씩 내 영역으로 (등급별 GlobalKey 위치) ──
    final afterState = ref.read(gameStateProvider);
    final newCaptured = afterState.playerCaptured.length - state.playerCaptured.length;

    if (newCaptured > 0) {
      for (var i = 0; i < newCaptured && i < 4; i++) {
        if (!mounted) return;
        final capturedCard = afterState.playerCaptured[afterState.playerCaptured.length - newCaptured + i];
        final dest = _getCapturedGroupPosition(capturedCard.def.grade);
        setState(() {
          _flyingCards = [
            FlyingCard(
              card: capturedCard,
              from: Offset(targetX + (i * 15), targetY),
              to: dest,
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

    // 애니메이션 정리
    if (mounted) {
      setState(() => _flyingCards = []);
    }

    // AI 턴 감지 → 애니메이션 처리
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final stateAfterPlay = ref.read(gameStateProvider);
    final isPending = ref.read(goStopPendingProvider); // 고/스톱 대기 중인지 확인

    // 대기 중(isPending)이 아닐 때만 AI 턴 즉시 진행. 대기 중이라면 GoStopOverlay의 onGo에서 처리함.
    if (stateAfterPlay.currentTurn == 'opponent' && !stateAfterPlay.isFinished && !isPending) {
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
    
    // 매칭 카드 위치 계산 (기본 필드 중앙)
    double targetX = screenW * 0.45;
    double targetY = screenH * 0.38;

    // AI 카드 타겟의 실제 화면 위치 추적
    final matchable = findMatchableCards(aiCard, prevState.field);
    if (matchable.isNotEmpty) {
      final actualTarget = matchable.first; // AI는 자동 타겟(가장 앞의 같은 월)을 사용
      final key = _fieldCardKeys[actualTarget];
      if (key != null && key.currentContext != null) {
        final box = key.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          targetX = position.dx;
          targetY = position.dy;
        }
      }
    }

    // ── STEP 1: AI 카드 → 필드로 던짐 ──
    setState(() {
      _flyingCards = [
        FlyingCard(
          card: aiCard,
          from: Offset(screenW * 0.45, 30),  // 상대 핸드 영역 (상단)
          to: Offset(targetX, targetY),
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

    // AI 플레이 후 고/스톱 또는 종료 상태면 애니메이션 중단
    final postAiState = ref.read(gameStateProvider);
    final postAiPending = ref.read(goStopPendingProvider);
    if (postAiState.isFinished || postAiPending) {
      if (mounted) setState(() => _flyingCards = []);
      return;
    }

    // ── STEP 2: 덱에서 카드 뒤집기 → 필드 ──
    final updatedState = ref.read(gameStateProvider);
    if (updatedState.deck.isNotEmpty) {
      setState(() {
        _flyingCards = [
          FlyingCard(
            card: updatedState.deck.isNotEmpty ? updatedState.deck.first : aiCard,
            from: const Offset(50, 280),
            to: Offset(targetX + 40, targetY + 10),
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

    // ── STEP 3: 획득 카드 → 상대 등급별 영역으로 순차 이동 ──
    final afterState = ref.read(gameStateProvider);
    final newCaptured = afterState.opponentCaptured.length - prevState.opponentCaptured.length;

    if (newCaptured > 0) {
      for (var i = 0; i < newCaptured && i < 4; i++) {
        if (!mounted) return;
        final capturedCard = afterState.opponentCaptured[afterState.opponentCaptured.length - newCaptured + i];
        final dest = _getOpponentCapturedGroupPosition(capturedCard.def.grade);
        setState(() {
          _flyingCards = [
            FlyingCard(
              card: capturedCard,
              from: Offset(targetX + (i * 15), targetY),
              to: dest,
              startAngle: -0.05,
              endAngle: 0.0,
              duration: const Duration(milliseconds: 280),
              size: 40,
            ),
          ];
        });
        await Future.delayed(const Duration(milliseconds: 220));
      }
    }

    if (mounted) {
      setState(() => _flyingCards = []);
    }

    // AI 턴 후 상태 확인: 게임 안 끝났고 여전히 AI 턴이면 재실행
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final finalState = ref.read(gameStateProvider);
    final pendingGoStop = ref.read(goStopPendingProvider);
    if (!finalState.isFinished && finalState.currentTurn == 'opponent' && !pendingGoStop) {
      await _executeAiTurn();
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

    // ── STEP 3: 획득 카드들 내 영역으로 (등급별 GlobalKey 위치) ──
    final afterState = ref.read(gameStateProvider);
    final newCaptured = afterState.playerCaptured.length - state.playerCaptured.length;

    if (newCaptured > 0) {
      for (var i = 0; i < newCaptured && i < 6; i++) {
        if (!mounted) return;
        final capturedCard = afterState.playerCaptured[afterState.playerCaptured.length - newCaptured + i];
        final dest = _getCapturedGroupPosition(capturedCard.def.grade);
        setState(() {
          _flyingCards = [
            FlyingCard(
              card: capturedCard,
              from: Offset(fieldCenterX, fieldCenterY),
              to: dest,
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

    // AI 턴 감지 → 실행
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final stateAfterBomb = ref.read(gameStateProvider);
    final isPending = ref.read(goStopPendingProvider);
    if (stateAfterBomb.currentTurn == 'opponent' && !stateAfterBomb.isFinished && !isPending) {
      await _executeAiTurn();
    }
  }

  // ─── 사이드 패널 ─────────────





  // ─── 고/스톱 오버레이 ─────────

  // ─── 카드 선택 오버레이 (같은 월 2장) ─────


  /// #4 족보 달성 알림 (화면 중앙 황금 플래시)


  /// #7 족보 진행도 (사이드 패널 하단용)




  // ─── 고/스톱 오버레이 (기존) ─────────
  /// AI 고/스톱 화면 중앙 빨간 글자 애니메이션




  // ─── 라운드 종료 오버레이 (개선) ──────





  void _showSkillSelectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final run = ref.watch(runStateNotifierProvider);
            final availableSkills = run.inventorySkills.entries.where((e) => e.value > 0).toList();
            final s = ref.watch(appStringsProvider);

            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(s.activeSkillTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 320,
                child: availableSkills.isEmpty
                  ? Padding(padding: const EdgeInsets.all(16.0), child: Text(s.noSkillAvailable, style: const TextStyle(color: Colors.white70)))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: availableSkills.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, idx) {
                        final skillId = availableSkills[idx].key;
                        final count = availableSkills[idx].value;
                        final itemInfo = findCatalogItem(skillId);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          tileColor: Colors.blueAccent.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          leading: Text(itemInfo?.emoji ?? '⚡', style: const TextStyle(fontSize: 28)),
                          title: Text(s.getItemName(skillId, itemInfo?.nameKo ?? skillId), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(s.remainingCount(count), style: const TextStyle(color: Colors.white54)),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _handleSkillUse(context, ref, skillId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(s.useBtn, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(s.closeBtn, style: const TextStyle(color: Colors.white54)),
                )
              ],
            );
          },
        );
      },
    );
  }

  /// 스킬 사용 분기: 추가 선택이 필요한 스킬은 별도 다이얼로그
  void _handleSkillUse(BuildContext context, WidgetRef ref, String skillId) {
    final normalizedId = migrateItemId(skillId);
    switch (normalizedId) {
      case 'a_joker':
        _showJokerSelectDialog(context, ref);
      case 'a_trick':
        _showTrickSelectDialog(context, ref);
      case 'a_card_laundry':
        _showLaundrySelectDialog(context, ref);
      case 'a_keen_eye':
        _showKeenEyeDialog(context, ref);
      default:
        ref.read(gameStateProvider.notifier).useActiveSkill(skillId);
    }
  }

  /// [조커] 바닥 카드 선택 다이얼로그
  void _showJokerSelectDialog(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameStateProvider);
    final s = ref.read(appStringsProvider);
    if (gameState.field.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('🃏 ${s.selectCardToCapture}', style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 350,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: gameState.field.map((card) {
              final gradeName = _gradeLabel(card.def.grade, s);
              return InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref.read(gameStateProvider.notifier).useJokerOnCard(card);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _gradeColor(card.def.grade).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _gradeColor(card.def.grade).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${card.def.month}${s.ui('monthLabel')}', style: TextStyle(color: _gradeColor(card.def.grade), fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(gradeName, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.closeBtn, style: const TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  /// [속임수] 바닥 카드 선택 → 핸드 카드 선택
  void _showTrickSelectDialog(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameStateProvider);
    final s = ref.read(appStringsProvider);
    if (gameState.field.isEmpty || gameState.playerHand.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('🎭 ${s.selectFieldCard}', style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 350,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(gameState.field.length, (i) {
              final card = gameState.field[i];
              return InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showTrickHandSelect(context, ref, i);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${card.def.month}${s.ui('monthLabel')}', style: const TextStyle(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(_gradeLabel(card.def.grade, s), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.closeBtn, style: const TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _showTrickHandSelect(BuildContext context, WidgetRef ref, int fieldIndex) {
    final gameState = ref.read(gameStateProvider);
    final s = ref.read(appStringsProvider);
    // 핸드 카드의 고유 월 목록
    final months = gameState.playerHand.map((c) => c.def.month).toSet().toList()..sort();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('🎭 ${s.selectHandCard}', style: const TextStyle(color: Colors.cyan, fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: months.map((month) {
              return InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref.read(gameStateProvider.notifier).useTrickOnCards(fieldIndex, month);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                  ),
                  child: Text('$month${s.ui('monthLabel')}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.closeBtn, style: const TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  /// [카드 세탁] 바닥 카드 선택 다이얼로그
  void _showLaundrySelectDialog(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameStateProvider);
    final s = ref.read(appStringsProvider);
    if (gameState.field.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('🧹 ${s.selectFieldCard}', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 350,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(gameState.field.length, (i) {
              final card = gameState.field[i];
              return InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref.read(gameStateProvider.notifier).useLaundryOnCard(i);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${card.def.month}${s.ui('monthLabel')}', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(_gradeLabel(card.def.grade, s), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.closeBtn, style: const TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  /// [눈썰미] 덱 상위 3장 확인 + 순서 변경 다이얼로그
  void _showKeenEyeDialog(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameStateProvider);
    final s = ref.read(appStringsProvider);
    final deckLen = gameState.deck.length;
    final topCount = deckLen < 3 ? deckLen : 3;
    if (topCount == 0) return;

    final topCards = gameState.deck.sublist(0, topCount);
    // 인덱스 순서 관리용
    final order = List<int>.generate(topCount, (i) => i);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('👁️ ${s.peekTop3}', style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(order.length, (i) {
                  final cardIdx = order[i];
                  final card = topCards[cardIdx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        // 순서 번호
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Text('${i + 1}', style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        // 카드 정보
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _gradeColor(card.def.grade).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _gradeColor(card.def.grade).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '${card.def.month}${s.ui('monthLabel')} ${_gradeLabel(card.def.grade, s)} - ${card.def.nameKo}',
                              style: TextStyle(color: _gradeColor(card.def.grade), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // 위로 버튼
                        if (i > 0)
                          IconButton(
                            icon: const Icon(Icons.arrow_upward, size: 18),
                            color: Colors.white54,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            onPressed: () {
                              setDialogState(() {
                                final tmp = order[i];
                                order[i] = order[i - 1];
                                order[i - 1] = tmp;
                              });
                            },
                          )
                        else
                          const SizedBox(width: 28),
                        // 아래로 버튼
                        if (i < order.length - 1)
                          IconButton(
                            icon: const Icon(Icons.arrow_downward, size: 18),
                            color: Colors.white54,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            onPressed: () {
                              setDialogState(() {
                                final tmp = order[i];
                                order[i] = order[i + 1];
                                order[i + 1] = tmp;
                              });
                            },
                          )
                        else
                          const SizedBox(width: 28),
                      ],
                    ),
                  );
                }),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(s.closeBtn, style: const TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(gameStateProvider.notifier).useKeenEyeReorder(order);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: Text(s.confirmBtn, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 흔들기 체크: 딜링 완료 후 호출 (복수 월 대응 — 2벌이면 전체 흔들기로 4배)
  void _checkShake() {
    final shakeMonths = ref.read(gameStateProvider.notifier).getShakeMonths();
    if (shakeMonths.isEmpty) return;
    final s = ref.read(appStringsProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Text('🫨', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(s.shakeTitle, style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          shakeMonths.length > 1
              ? '${shakeMonths.map((m) => s.shakeDesc(m)).join('\n')}\n\n${s.shakeAllDesc(shakeMonths.length)}'
              : s.shakeDesc(shakeMonths.first),
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.shakePass, style: const TextStyle(color: Colors.white54, fontSize: 15)),
          ),
          // 2벌 이상이면 "전체 흔들기" 버튼 (4배+)
          if (shakeMonths.length > 1)
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(gameStateProvider.notifier).declareShakeAll(shakeMonths);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                '${s.shakeAllDeclare} (x${pow(2, shakeMonths.length).toInt()})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          // 각 월별 개별 흔들기 버튼
          for (final month in shakeMonths)
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(gameStateProvider.notifier).declareShake(month);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                shakeMonths.length > 1
                    ? '${s.shakeDeclare} (${s.monthFormatted(month)})'
                    : s.shakeDeclare,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
        ],
      ),
    );
  }

  /// 플레이어 획득 영역에서 등급별 그룹의 실제 화면 위치 반환
  Offset _getCapturedGroupPosition(CardGrade grade) {
    final key = switch (grade) {
      CardGrade.bright => _capturedBrightKey,
      CardGrade.animal => _capturedAnimalKey,
      CardGrade.ribbon => _capturedRibbonKey,
      CardGrade.junk   => _capturedJunkKey,
    };
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final pos = renderBox.localToGlobal(Offset.zero);
      return Offset(pos.dx + renderBox.size.width - 20, pos.dy);
    }
    return Offset(_screenW * 0.4, _screenH - _playerHandHeight - _capturedAreaHeight / 2);
  }

  /// 상대 획득 영역에서 등급별 그룹의 실제 화면 위치 반환
  Offset _getOpponentCapturedGroupPosition(CardGrade grade) {
    final key = switch (grade) {
      CardGrade.bright => _opCapturedBrightKey,
      CardGrade.animal => _opCapturedAnimalKey,
      CardGrade.ribbon => _opCapturedRibbonKey,
      CardGrade.junk   => _opCapturedJunkKey,
    };
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final pos = renderBox.localToGlobal(Offset.zero);
      return Offset(pos.dx + renderBox.size.width - 20, pos.dy);
    }
    // fallback: 상단 획득 영역 (등급별 수평 오프셋)
    final gradeOffset = switch (grade) {
      CardGrade.bright => 0.0,
      CardGrade.animal => 60.0,
      CardGrade.ribbon => 120.0,
      CardGrade.junk   => 180.0,
    };
    return Offset(_screenW * 0.25 + gradeOffset, _capturedAreaHeight / 2);
  }

  /// 카드 등급별 색상 (다이얼로그용)
  Color _gradeColor(CardGrade grade) {
    switch (grade) {
      case CardGrade.bright:
        return Colors.amber;
      case CardGrade.animal:
        return Colors.cyan;
      case CardGrade.ribbon:
        return Colors.red;
      case CardGrade.junk:
        return Colors.grey;
    }
  }

  /// 카드 등급 라벨 (다이얼로그용)
  String _gradeLabel(CardGrade grade, AppStrings s) {
    switch (grade) {
      case CardGrade.bright:
        return s.ui('cardGradeBright');
      case CardGrade.animal:
        return s.ui('cardGradeAnimal');
      case CardGrade.ribbon:
        return s.ui('cardGradeRibbon');
      case CardGrade.junk:
        return s.ui('cardGradeJunk');
    }
  }
}


/// 화투판 바닥 패턴 페인터 (스테이지별 다른 질감)
// ignore: unused_element
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
