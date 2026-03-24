/// 🎴 K-Poker — 게임 오버레이 위젯 모음
///
/// game_screen.dart에서 분리된 오버레이/팝업 관련 위젯:
/// - GameStartOverlay: 게임 시작 화면 (5광 부채살 + K-Poker 로고)
/// - CardSelectOverlay: 같은 월 2장+ 선택 오버레이
/// - GoStopOverlay: 고/스톱 결정 오버레이
/// - AiGoStopAnimation: AI 고/스톱 알림 애니메이션
/// - RoundEndOverlay: 라운드 종료 (승리/패배/파산)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/game_providers.dart';
import '../../models/card_def.dart';
import '../../data/stage_config.dart';
import 'hwatu_card.dart';

// ═══════════════════════════════════════════════════════════════
// 게임 시작 오버레이
// ═══════════════════════════════════════════════════════════════

class GameStartOverlay extends ConsumerWidget {
  final dynamic strings;
  final VoidCallback onStart;
  final VoidCallback onSettings;
  final VoidCallback onTutorial;

  const GameStartOverlay({
    super.key,
    required this.strings,
    required this.onStart,
    required this.onSettings,
    required this.onTutorial,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brightIds = ['m01_bright', 'm03_bright', 'm08_bright', 'm11_bright', 'm12_bright'];
    const fanAngle = 0.18;
    final run = ref.watch(runStateNotifierProvider);
    final stageConfig = getStageConfig(run.stage);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);
    final currency = getCurrencyForLocale(run.currencyLocale);
    
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
                    onPressed: onStart,
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
                  onPressed: onTutorial,
                  icon: const Text('❓', style: TextStyle(fontSize: 20)),
                  tooltip: '도움말',
                ),
                IconButton(
                  onPressed: onSettings,
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
}

// ═══════════════════════════════════════════════════════════════
// 카드 선택 오버레이 (같은 월 2장+)
// ═══════════════════════════════════════════════════════════════

class CardSelectOverlay extends StatelessWidget {
  final List<CardInstance> selectableFieldCards;
  final void Function(CardInstance) onSelect;
  final VoidCallback onCancel;

  const CardSelectOverlay({
    super.key,
    required this.selectableFieldCards,
    required this.onSelect,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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
              Text('같은 월 카드가 ${selectableFieldCards.length}장 있습니다', style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var fc in selectableFieldCards)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelect(fc),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.cyan, width: 2),
                            boxShadow: [BoxShadow(color: Colors.cyan.withValues(alpha: 0.4), blurRadius: 12)],
                          ),
                          child: AbsorbPointer(
                            child: HwatuCard(card: fc, size: 90),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCancel,
                child: const Text('취소', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AI 고/스톱 애니메이션
// ═══════════════════════════════════════════════════════════════

class AiGoStopAnimation extends StatelessWidget {
  final String announce;

  const AiGoStopAnimation({super.key, required this.announce});

  @override
  Widget build(BuildContext context) {
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
}

// ═══════════════════════════════════════════════════════════════
// 고/스톱 결정 오버레이
// ═══════════════════════════════════════════════════════════════

class GoStopOverlay extends ConsumerWidget {
  final dynamic strings;
  final Future<void> Function() onGo;
  final VoidCallback onStop;

  const GoStopOverlay({
    super.key,
    required this.strings,
    required this.onGo,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.read(gameStateProvider);
    final pBright = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.bright).length;
    final pAnimal = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.animal).length;
    final pRibbon = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.ribbon).length;
    final pJunk = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.junk).length;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 3)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    const Text('나', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('${state.playerScore}점', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.bold)),
                  ]),
                  const Text('VS', style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold)),
                  Column(children: [
                    const Text('상대', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('${state.opponentScore}점', style: const TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _goStopChip('⭐', '광', pBright, const Color(0xFFFFD700)),
                    _goStopChip('🦌', '동물', pAnimal, const Color(0xFF00E5FF)),
                    _goStopChip('🎀', '띄', pRibbon, const Color(0xFFFF4081)),
                    _goStopChip('🎴', '피', pJunk, const Color(0xFF78909C)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                state.goCount == 0
                    ? '🔥 3점 달성!'
                    : '${'🔥' * (state.goCount + 1)} ${state.goCount + 1}고! 추가 점수!',
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                state.goCount == 0
                    ? '고 → 배율 2배 | 지면 2배 손해'
                    : '현재 배율 ${state.multiplier.toInt()}배 → 고 시 ${(state.multiplier * 2).toInt()}배!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => onGo(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(strings.goDecision, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: onStop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(strings.stopDecision, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 라운드 종료 오버레이 (승리/패배/파산)
// ═══════════════════════════════════════════════════════════════

class RoundEndOverlay extends ConsumerWidget {
  final dynamic state;
  final dynamic strings;
  final double screenW;
  final double scale;
  final VoidCallback onNextRound;
  final VoidCallback onShop;
  final VoidCallback onRestart;

  const RoundEndOverlay({
    super.key,
    required this.state,
    required this.strings,
    required this.screenW,
    required this.scale,
    required this.onNextRound,
    required this.onShop,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWin = state.playerScore > state.opponentScore;
    final run = ref.watch(runStateNotifierProvider);
    final currency = getCurrencyForLocale(run.currencyLocale);
    final isBankrupt = !isWin && ref.read(runStateNotifierProvider.notifier).isBankrupt;
    
    final pBright = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.bright).length;
    final pAnimal = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.animal).length;
    final pRibbon = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.ribbon).length;
    final pJunk = state.playerCaptured.where((CardInstance c) => c.def.grade == CardGrade.junk).length;

    final baseScore = state.baseChips;
    final mult = state.multiplier;
    final earnings = isWin
        ? baseScore * currency.pointValue * mult
        : -(state.opponentScore > 0 ? state.opponentScore : 1) * currency.pointValue;

    if (isBankrupt) {
      return _buildBankruptOverlay(state, run, currency);
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: screenW * 0.85 > 380 ? 380 : screenW * 0.85),
          padding: EdgeInsets.all(scale > 0.7 ? 28 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isWin ? const Color(0xFFFFD700) : Colors.redAccent, width: 2),
            boxShadow: [BoxShadow(color: (isWin ? Colors.amber : Colors.red).withValues(alpha: 0.3), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScoreVersusHeader(state: state),
              const SizedBox(height: 16),
              Text(isWin ? '🏆' : '💀', style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(isWin ? '승리!' : '패배...',
                style: TextStyle(color: isWin ? const Color(0xFFFFD700) : Colors.redAccent, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    resultBadge('🌟', '$pBright', '광'),
                    resultBadge('🐾', '$pAnimal', '동물'),
                    resultBadge('🎀', '$pRibbon', '띠'),
                    resultBadge('🍂', '$pJunk', '피'),
                    if (state.sweepCount > 0)
                      resultBadge('🧹', '${state.sweepCount}', '쓸'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isWin)
                    OutlinedButton.icon(
                      onPressed: onShop,
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
                    onPressed: onNextRound,
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

  Widget _buildBankruptOverlay(dynamic state, dynamic run, dynamic currency) {
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: screenW * 0.85 > 380 ? 380 : screenW * 0.85),
          padding: EdgeInsets.all(scale > 0.7 ? 28 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.redAccent, width: 3),
            boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScoreVersusHeader(state: state),
              const SizedBox(height: 16),
              const Text('💸', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              const Text('파산!', style: TextStyle(
                color: Colors.redAccent, fontSize: 36, fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.red, blurRadius: 20)],
              )),
              const SizedBox(height: 8),
              const Text('소지금이 바닥났습니다...', style: TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    gameOverStatRow('🏆 총 승리', '${run.wins}승'),
                    gameOverStatRow('💀 총 패배', '${run.losses}패'),
                    gameOverStatRow('🔥 최고 연승', '${run.winStreak}연승'),
                    gameOverStatRow('⭐ 최고 점수', '${run.highestScore}점'),
                    gameOverStatRow('💰 최고 소지금', currency.formatExact(run.highestMoney)),
                    gameOverStatRow('📍 도달 스테이지', '스테이지 ${run.stage}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRestart,
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
}

// ═══════════════════════════════════════════════════════════════
// 공통 유틸 위젯
// ═══════════════════════════════════════════════════════════════

class ScoreVersusHeader extends StatelessWidget {
  final dynamic state;

  const ScoreVersusHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const Text('👤 나', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${state.playerScore}점', style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 24),
          const Text('VS', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          const SizedBox(width: 24),
          Column(
            children: [
               const Text('🤖 상대', style: TextStyle(color: Colors.white70, fontSize: 12)),
               Text('${state.opponentScore}점', style: const TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _goStopChip(String emoji, String label, int count, Color color) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 2),
      Text('$label $count', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    ],
  );
}

Widget resultBadge(String emoji, String value, String label) {
  return Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
    ],
  );
}

Widget gameOverStatRow(String label, String value) {
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
