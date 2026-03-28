/// 🎴 K-Poker — 사이드 패널 위젯 (게임 정보 패널)
///
/// game_screen.dart에서 분리된 사이드 패널 관련 위젯 모음:
/// - GameSidePanel: 전체 사이드 패널
/// - SidePanelToggle: 열기/닫기 토글 버튼
/// - OpponentSummaryBlock: 상대 정보 블록
/// - MySummaryBlock: 내 정보 블록
/// - YakuProgress: 족보 진행도
/// - MySkillsBlock: 내 아이템/스킬 블록
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/game_providers.dart';
import '../../models/card_def.dart';
import '../../data/stage_config.dart';
import '../../data/item_catalog.dart';
import '../../i18n/app_strings.dart';
import '../../i18n/locale_provider.dart';

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
    final strings = ref.watch(appStringsProvider);

    return Container(
      width: 140, // 200 -> 140 (약 2/3 수준)
      color: const Color(0xFF0D1117),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isShort = constraints.maxHeight < 450;
          
          if (isShort) {
            // 짧은 화면일 때는 스크롤뷰로 전체를 감싼 형태 반환
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OpponentSummaryBlock(state: state, run: run, ai: ai, currency: currency, strings: strings),
                  Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, thickness: 1),
                  MySummaryBlock(state: state, run: run, currency: currency, strings: strings),
                  Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        YakuProgress(state: state, strings: strings),
                        const SizedBox(height: 8),
                        MySkillsBlock(run: run),
                      ],
                    ),
                  ),
                  Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, thickness: 1),
                  SizedBox(
                    height: 120, // 스크롤 시 로그가 보일 수 있도록 고정 크기 할당
                    child: _buildLogList(events),
                  ),
                ],
              ),
            );
          }

          // 기본 레이아웃
          return Column(
            children: [
              // 1. 상대 정보
              OpponentSummaryBlock(state: state, run: run, ai: ai, currency: currency, strings: strings),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, thickness: 1),

              // 2. 내 정보
              MySummaryBlock(state: state, run: run, currency: currency, strings: strings),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, thickness: 1),

              // 3. 족보 진행도 및 스킬 가방
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      YakuProgress(state: state, strings: strings),
                      const SizedBox(height: 8),
                      MySkillsBlock(run: run),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, thickness: 1),

              // 4. 게임 로그 (약 4줄 정도 보이도록 85px로 조정)
              SizedBox(
                height: 85,
                child: _buildLogList(events),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogList(List<GameEvent> events) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final reversedIndex = events.length - 1 - index;
        final event = events[reversedIndex];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: event.type == 'ai_talk' 
                  ? Colors.purple.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Text(
              event.message,
              style: TextStyle(
                color: event.type == 'ai_talk' ? Colors.purpleAccent.shade100 : Colors.white60,
                fontSize: 9, // 엄청 작은 게임 로그
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── 상대 정보 블록 ─────────────
class OpponentSummaryBlock extends StatelessWidget {
  final dynamic state;
  final dynamic run;
  final dynamic ai;
  final dynamic currency;
  final AppStrings strings;

  const OpponentSummaryBlock({
    super.key,
    required this.state,
    required this.run,
    required this.ai,
    required this.currency,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final oppFund = getOpponentFund(run.stage, run.currentOpponentIndex, currency.pointValue);
    final oppMoneyLeft = run.opponentMoney.clamp(0.0, oppFund);

    int kwang = 0, animal = 0, blue = 0, red = 0, grass = 0, plain = 0, pi = 0;
    for (var c in state.opponentCaptured) {
      if (c.def.grade == CardGrade.bright) {
        kwang++;
      } else if (c.def.grade == CardGrade.animal) {
        animal++;
      } else if (c.def.grade == CardGrade.ribbon) {
        if (c.def.ribbonType == RibbonType.blue) {
          blue++;
        } else if (c.def.ribbonType == RibbonType.red) {
          red++;
        } else if (c.def.ribbonType == RibbonType.grass) {
          grass++;
        } else {
          plain++;
        }
      } else if (c.def.grade == CardGrade.junk) {
        pi += c.def.doubleJunk ? 2 : 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.redAccent.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('${ai.emoji} ${strings.ui('opponent')}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${state.opponentScore}', style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('💰 ${currency.formatAmount(oppMoneyLeft)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('🎴 ${strings.ui('handStatus')}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 2, runSpacing: 2,
            children: [
              if (kwang > 0) _miniTag('${strings.ui('kwang')} $kwang', Colors.amber),
              if (animal > 0) _miniTag('${strings.ui('animal')} $animal', Colors.cyan),
              if (blue > 0) _miniTag('${strings.ui('blue')} $blue', Colors.blue),
              if (red > 0) _miniTag('${strings.ui('red')} $red', Colors.red),
              if (grass > 0) _miniTag('${strings.ui('grass')} $grass', Colors.green),
              if (plain > 0) _miniTag('${strings.ui('plain')} $plain', Colors.purple),
              if (pi > 0) _miniTag('${strings.ui('pi')} $pi', Colors.grey),
              if (kwang==0 && animal==0 && blue==0 && red==0 && grass==0 && plain==0 && pi==0)
                Text(strings.ui('none'), style: const TextStyle(color: Colors.white30, fontSize: 9)),
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
  final AppStrings strings;

  const MySummaryBlock({
    super.key,
    required this.state,
    required this.run,
    required this.currency,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blueAccent.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('👤 ${strings.ui('myInfo')}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              if (run.winStreak > 0)
                Text('🔥${run.winStreak}${strings.ui('winStreak')}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('💰 ${currency.formatAmount(run.money)}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strings.ui('currentScore'), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
              Text('${state.playerScore} × ${state.multiplier.toStringAsFixed(1)}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
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
  final AppStrings strings;

  const YakuProgress({super.key, required this.state, required this.strings});

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
        Text('📊 ${strings.ui('yakuProgress')}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        _yakuBar('⭐ ${strings.ui('kwang')}', brights, 3, Colors.amber),
        _yakuBar('🔴 ${strings.ui('red')}', redRibbons, 3, Colors.red),
        _yakuBar('🔵 ${strings.ui('blue')}', blueRibbons, 3, Colors.blue),
        _yakuBar('🟢 ${strings.ui('grass')}', grassRibbons, 3, Colors.green),
        _yakuBar('🦌 ${strings.ui('animal')}', animals, 5, Colors.cyan),
        _yakuBar('🃏 ${strings.ui('pi')}', junks, 10, Colors.grey),
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
          SizedBox(width: 45, child: Text(name, style: TextStyle(
            color: isComplete ? color : Colors.white54, fontSize: 9,
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
class MySkillsBlock extends ConsumerWidget {
  final dynamic run;

  const MySkillsBlock({super.key, required this.run});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStr = ref.watch(appStringsProvider);
    final gameState = ref.watch(gameStateProvider);
    final isPlayerTurn = gameState.currentTurn == 'player' && !gameState.isFinished;

    // 신규 시스템: inventorySkills (Map<String, int>) + ownedTalismanIds (List<String>) + ownedPassiveIds (List<String>)
    final Map<String, int> invSkills = run.inventorySkills as Map<String, int>;
    final List<String> talismanIds = run.ownedTalismanIds as List<String>;
    final List<String> passiveIds = run.ownedPassiveIds as List<String>;

    // 수량 > 0인 스킬만 표시
    final activeEntries = invSkills.entries.where((e) => e.value > 0).toList();
    final bool hasNothing = activeEntries.isEmpty && talismanIds.isEmpty && passiveIds.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🎒 ${appStr.ui('skillBag')}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (hasNothing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(appStr.ui('noSkills'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white30, fontSize: 9)),
          )
        else
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              // 패시브 스킬 — ownedPassiveIds 기반 (노란/주황 테두리)
              for (var pId in passiveIds)
                _buildPassiveChip(pId, appStr),
              // 부적 (영구 패시브) — ownedTalismanIds 기반
              for (var tId in talismanIds)
                _buildTalismanChip(tId, appStr),
              // 액티브 스킬 — inventorySkills 기반
              for (var entry in activeEntries)
                _buildSkillChip(context, ref, entry.key, entry.value, isPlayerTurn, appStr),
            ],
          ),
      ],
    );
  }

  Widget _buildPassiveChip(String passiveId, AppStrings appStr) {
    final itemInfo = findCatalogItem(passiveId);
    final emoji = itemInfo?.emoji ?? '🔮';
    final name = appStr.getItemName(passiveId, itemInfo?.nameKo ?? passiveId);
    final desc = appStr.getItemDesc(passiveId, itemInfo?.description ?? '');

    return Tooltip(
      message: '$name\n$desc',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orangeAccent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 2),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildTalismanChip(String talismanId, AppStrings appStr) {
    final itemInfo = findCatalogItem(talismanId);
    final emoji = itemInfo?.emoji ?? '📜';
    final name = appStr.getItemName(talismanId, itemInfo?.nameKo ?? talismanId);
    final desc = appStr.getItemDesc(talismanId, itemInfo?.description ?? '');

    return Tooltip(
      message: '$name\n$desc',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.deepPurpleAccent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 2),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(
    BuildContext context,
    WidgetRef ref,
    String skillId,
    int count,
    bool isPlayerTurn,
    AppStrings appStr,
  ) {
    final itemInfo = findCatalogItem(skillId);
    final emoji = itemInfo?.emoji ?? '⚡';
    final name = appStr.getItemName(skillId, itemInfo?.nameKo ?? skillId);
    final desc = appStr.getItemDesc(skillId, itemInfo?.description ?? '');

    return Tooltip(
      message: '$name\n$desc',
      child: InkWell(
        onTap: isPlayerTurn
            ? () {
                ref.read(gameStateProvider.notifier).useActiveSkill(skillId);
              }
            : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isPlayerTurn
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isPlayerTurn ? Colors.greenAccent : Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 2),
              Text(name, style: TextStyle(
                color: isPlayerTurn ? Colors.white : Colors.white38,
                fontSize: 9,
              )),
              const SizedBox(width: 2),
              // 수량 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('x$count', style: TextStyle(
                  color: isPlayerTurn ? Colors.cyanAccent : Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                )),
              ),
            ],
          ),
        ),
      ),
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
    child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
  );
}


