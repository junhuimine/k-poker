/// 🎴 K-Poker — 사이드 패널 위젯 (게임 정보 패널)
///
/// game_screen.dart에서 분리된 사이드 패널 관련 위젯 모음:
/// - GameSidePanel: 전체 사이드 패널
/// - SidePanelToggle: 열기/닫기 토글 버튼
/// - OpponentSummaryBlock: 상대 정보 블록
/// - MySummaryBlock: 내 정보 블록
/// - YakuProgress: 족보 진행도
/// - MySkillsBlock: 내 아이템/스킬 블록

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/game_providers.dart';
import '../../models/card_def.dart';
import '../../data/stage_config.dart';

// ─── 사이드 패널 토글 버튼 ─────────────
class SidePanelToggle extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;

  const SidePanelToggle({
    super.key,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 24,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(
            isOpen ? '»' : '«',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 사이드 패널 본체 ─────────────
class GameSidePanel extends ConsumerWidget {
  final dynamic state;
  final List<GameEvent> events;

  const GameSidePanel({
    super.key,
    required this.state,
    required this.events,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(runStateNotifierProvider);
    final currency = getCurrencyForLocale(run.currencyLocale);
    final ai = getAiForStage(run.stage, run.currentOpponentIndex);

    return Container(
      width: 200,
      color: const Color(0xFF0D1117),
      child: Column(
        children: [
          // 1. 상대 정보
          OpponentSummaryBlock(state: state, run: run, ai: ai, currency: currency),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),

          // 2. 내 정보
          MySummaryBlock(state: state, run: run, currency: currency),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),

          // 3. 족보 진행도
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YakuProgress(state: state),
                  const SizedBox(height: 8),
                  MySkillsBlock(run: run),
                ],
              ),
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),

          // 4. 게임 로그
          SizedBox(
            height: 130,
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(6),
              itemCount: events.length,
              itemBuilder: (_, i) {
                final event = events[events.length - 1 - i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: _eventColor(event.type).withValues(alpha: 0.1),
                      border: Border.all(color: _eventColor(event.type).withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.message,
                      style: TextStyle(color: _eventColor(event.type), fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}

// ─── 상대 정보 블록 ─────────────
class OpponentSummaryBlock extends StatelessWidget {
  final dynamic state;
  final dynamic run;
  final dynamic ai;
  final dynamic currency;

  const OpponentSummaryBlock({
    super.key,
    required this.state,
    required this.run,
    required this.ai,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final oppFund = getOpponentFund(run.stage, run.currentOpponentIndex, currency.pointValue);
    final oppMoneyLeft = run.opponentMoney.clamp(0.0, oppFund);

    int kwang = 0, animal = 0, blue = 0, red = 0, grass = 0, plain = 0, pi = 0;
    for (var c in state.opponentCaptured) {
      if (c.def.grade == CardGrade.bright) kwang++;
      else if (c.def.grade == CardGrade.animal) animal++;
      else if (c.def.grade == CardGrade.ribbon) {
        if (c.def.ribbonType == RibbonType.blue) blue++;
        else if (c.def.ribbonType == RibbonType.red) red++;
        else if (c.def.ribbonType == RibbonType.grass) grass++;
        else plain++;
      }
      else if (c.def.grade == CardGrade.junk) pi += c.def.doubleJunk ? 2 : 1;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.redAccent.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('${ai.emoji} 상대 정보', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${state.opponentScore}점', style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('💰 ${currency.formatAmount(oppMoneyLeft)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('🎴 보유 패 현황', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4, runSpacing: 4,
            children: [
              if (kwang > 0) _miniTag('광 $kwang', Colors.amber),
              if (animal > 0) _miniTag('열끗 $animal', Colors.cyan),
              if (blue > 0) _miniTag('청단 $blue', Colors.blue),
              if (red > 0) _miniTag('홍단 $red', Colors.red),
              if (grass > 0) _miniTag('초단 $grass', Colors.green),
              if (plain > 0) _miniTag('띠 $plain', Colors.purple),
              if (pi > 0) _miniTag('피 $pi', Colors.grey),
              if (kwang==0 && animal==0 && blue==0 && red==0 && grass==0 && plain==0 && pi==0)
                const Text('없음', style: TextStyle(color: Colors.white30, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 내 정보 블록 ─────────────
class MySummaryBlock extends StatelessWidget {
  final dynamic state;
  final dynamic run;
  final dynamic currency;

  const MySummaryBlock({
    super.key,
    required this.state,
    required this.run,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blueAccent.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('👤 내 정보', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
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
    );
  }
}

// ─── 족보 진행도 ─────────────
class YakuProgress extends StatelessWidget {
  final dynamic state;

  const YakuProgress({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final captured = state.playerCaptured as List<CardInstance>;
    final brights = captured.where((c) => c.def.grade == CardGrade.bright).length;
    final animals = captured.where((c) => c.def.grade == CardGrade.animal).length;
    final redRibbons = captured.where((c) => c.def.ribbonType == RibbonType.red).length;
    final blueRibbons = captured.where((c) => c.def.ribbonType == RibbonType.blue).length;
    final grassRibbons = captured.where((c) => c.def.ribbonType == RibbonType.grass).length;
    final junks = captured.where((c) => c.def.grade == CardGrade.junk).fold<int>(0, (sum, c) {
      return sum + ((c.def.doubleJunk || c.def.isBonus) ? 2 : 1);
    });

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
}

// ─── 내 아이템/스킬 블록 ─────────────
class MySkillsBlock extends StatelessWidget {
  final dynamic run;

  const MySkillsBlock({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final skills = run.activeSkills as List<dynamic>;
    final talismans = run.activeTalismans as List<dynamic>;

    if (skills.isEmpty && talismans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🎒 내 아이템 / 스킬', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var t in talismans)
              Tooltip(
                message: '${t.nameKo}\n${t.description}',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepPurpleAccent, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(t.nameKo, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            for (var s in skills)
              Tooltip(
                message: '${s.nameKo}\n${s.description}',
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.nameKo} 스킬 사용!'), duration: const Duration(seconds: 1)));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.greenAccent, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(s.nameKo, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── 공통 유틸 ─────────────
Widget _miniTag(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withValues(alpha: 0.5)),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
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
