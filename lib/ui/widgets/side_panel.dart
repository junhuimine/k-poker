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
              Text('${state.baseChips > 0 ? state.baseChips : state.playerScore} × ${state.multiplier.toStringAsFixed(1)}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
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

    final Map<String, int> invSkills = run.inventorySkills as Map<String, int>;
    final Map<String, int> invRound = run.inventoryRoundItems as Map<String, int>;
    final List<String> equippedRound = run.equippedRoundItemIds as List<String>;
    final List<String> talismanIds = run.ownedTalismanIds as List<String>;
    final List<String> passiveIds = run.ownedPassiveIds as List<String>;

    final activeEntries = invSkills.entries.where((e) => e.value > 0).toList();
    final roundInvEntries = invRound.entries.where((e) => e.value > 0).toList();
    final bool hasNothing = activeEntries.isEmpty && talismanIds.isEmpty &&
        passiveIds.isEmpty && roundInvEntries.isEmpty && equippedRound.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🎒 ${appStr.ui('skillBag')}', style: const TextStyle(
            color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (hasNothing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(appStr.ui('noSkills'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white30, fontSize: 9)),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 패시브 (항상 자동 발동) ──
              if (passiveIds.isNotEmpty) ...[
                _sectionLabel('🔮 패시브', Colors.orange),
                Wrap(spacing: 3, runSpacing: 3, children: [
                  for (var pId in passiveIds) _buildPassiveChip(pId, appStr),
                ]),
                const SizedBox(height: 6),
              ],
              // ── 부적 (런 전체 영구 효과) ──
              if (talismanIds.isNotEmpty) ...[
                _sectionLabel('📜 부적', Colors.deepPurpleAccent),
                Wrap(spacing: 3, runSpacing: 3, children: [
                  for (var tId in talismanIds) _buildTalismanChip(tId, appStr),
                ]),
                const SizedBox(height: 6),
              ],
              // ── 인게임 액티브 (게임 중 즉발) ──
              if (activeEntries.isNotEmpty) ...[
                _sectionLabel('⚡ 즉발', Colors.greenAccent),
                Wrap(spacing: 3, runSpacing: 3, children: [
                  for (var e in activeEntries)
                    _buildActiveChip(context, ref, e.key, e.value,
                        isPlayerTurn, appStr, gameState),
                ]),
                const SizedBox(height: 6),
              ],
              // ── 라운드 소모품 (장착/미장착) ──
              if (equippedRound.isNotEmpty || roundInvEntries.isNotEmpty) ...[
                _sectionLabel('🎫 라운드 아이템', Colors.tealAccent),
                Wrap(spacing: 3, runSpacing: 3, children: [
                  for (var rId in equippedRound)
                    _buildRoundChip(ref, rId, true, appStr),
                  for (var e in roundInvEntries)
                    _buildRoundChip(ref, e.key, false, appStr, count: e.value),
                ]),
              ],
            ],
          ),
      ],
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(text, style: TextStyle(
          color: color.withValues(alpha: 0.8),
          fontSize: 9,
          fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPassiveChip(String passiveId, AppStrings appStr) {
    final item = findCatalogItem(passiveId);
    final name = appStr.getItemName(passiveId, item?.nameKo ?? passiveId);
    final desc = appStr.getItemDesc(passiveId, item?.descKo ?? item?.description ?? '');
    return Tooltip(
      message: '[$name]\n$desc',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orangeAccent, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(item?.emoji ?? '🔮', style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Flexible(child: Text(name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 9))),
          const SizedBox(width: 3),
          // 항상 켜져있음 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text('ON', style: TextStyle(
                color: Colors.greenAccent, fontSize: 7, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  Widget _buildTalismanChip(String talismanId, AppStrings appStr) {
    final item = findCatalogItem(talismanId);
    final name = appStr.getItemName(talismanId, item?.nameKo ?? talismanId);
    final desc = appStr.getItemDesc(talismanId, item?.descKo ?? item?.description ?? '');
    return Tooltip(
      message: '[$name]\n$desc',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.deepPurpleAccent, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(item?.emoji ?? '📜', style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Flexible(child: Text(name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 9))),
        ]),
      ),
    );
  }

  Widget _buildActiveChip(
    BuildContext context,
    WidgetRef ref,
    String skillId,
    int count,
    bool isPlayerTurn,
    AppStrings appStr,
    dynamic gameState,
  ) {
    final item = findCatalogItem(skillId);
    final name = appStr.getItemName(skillId, item?.nameKo ?? skillId);
    final desc = appStr.getItemDesc(skillId, item?.descKo ?? item?.description ?? '');
    final canUse = isPlayerTurn && count > 0;

    // 타겟 선택이 필요한 스킬 (다이얼로그 호출)
    final needsTarget = skillId == 'a_joker' || skillId == 'a_card_laundry' ||
        skillId == 'a_trick' || skillId == 'a_keen_eye';

    return Tooltip(
      message: '[$name]\n$desc\n${canUse ? "▶ 탭하여 사용" : "상대 턴에는 사용 불가"}',
      child: GestureDetector(
        onTap: canUse
            ? () => needsTarget
                ? _showTargetDialog(context, ref, skillId, name, appStr, gameState)
                : ref.read(gameStateProvider.notifier).useActiveSkill(skillId)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: canUse
                ? Colors.green.withValues(alpha: 0.25)
                : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: canUse ? Colors.greenAccent : Colors.grey,
              width: canUse ? 1.5 : 1,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(item?.emoji ?? '⚡', style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 3),
            Flexible(child: Text(name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: canUse ? Colors.white : Colors.white38,
                    fontSize: 9))),
            const SizedBox(width: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: canUse
                    ? Colors.cyanAccent.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('×$count', style: TextStyle(
                  color: canUse ? Colors.cyanAccent : Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildRoundChip(
    WidgetRef ref,
    String itemId,
    bool isEquipped,
    AppStrings appStr, {
    int count = 1,
  }) {
    final item = findCatalogItem(itemId);
    final name = appStr.getItemName(itemId, item?.nameKo ?? itemId);
    final desc = appStr.getItemDesc(itemId, item?.descKo ?? item?.description ?? '');

    return Tooltip(
      message: '[$name]\n$desc\n${isEquipped ? "✅ 이번 라운드 장착됨" : "▶ 탭하여 장착"}',
      child: GestureDetector(
        onTap: isEquipped
            ? null
            : () => ref.read(runStateNotifierProvider.notifier).equipRoundItem(itemId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: isEquipped
                ? Colors.teal.withValues(alpha: 0.3)
                : Colors.blueGrey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isEquipped ? Colors.tealAccent : Colors.blueGrey,
              width: isEquipped ? 1.5 : 1,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(item?.emoji ?? '🎫', style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 3),
            Flexible(child: Text(name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isEquipped ? Colors.tealAccent : Colors.white60,
                    fontSize: 9))),
            if (!isEquipped && count > 1) ...[
              const SizedBox(width: 3),
              Text('×$count', style: const TextStyle(
                  color: Colors.white38, fontSize: 8)),
            ],
            if (isEquipped) ...[
              const SizedBox(width: 3),
              const Text('✓', style: TextStyle(
                  color: Colors.tealAccent, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ]),
        ),
      ),
    );
  }

  void _showTargetDialog(
    BuildContext context,
    WidgetRef ref,
    String skillId,
    String skillName,
    AppStrings appStr,
    dynamic gameState,
  ) {
    final field = gameState.field as List;
    final notifier = ref.read(gameStateProvider.notifier);

    if (skillId == 'a_joker' || skillId == 'a_card_laundry') {
      if (field.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('바닥에 카드가 없습니다'), duration: const Duration(seconds: 2)),
        );
        return;
      }
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          title: Text(skillId == 'a_joker' ? '🃏 획득할 카드 선택' : '🧼 덱으로 보낼 카드 선택',
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          content: SizedBox(
            width: 200,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: field.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (_, i) {
                final card = field[i];
                return ListTile(
                  dense: true,
                  title: Text(card.def.nameKo ?? card.def.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                  subtitle: Text('${card.def.month}월',
                      style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  onTap: () {
                    Navigator.pop(context);
                    if (skillId == 'a_joker') {
                      notifier.useJokerOnCard(card);
                    } else {
                      notifier.useLaundryOnCard(i);
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      );
    } else if (skillId == 'a_keen_eye') {
      final deck = gameState.deck as List;
      final topCards = deck.take(3).toList();
      if (topCards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('덱이 비어있습니다'), duration: Duration(seconds: 2)),
        );
        return;
      }
      // 순서 변경: 현재 순서 유지(확인만)로 간소화
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          title: const Text('👁️ 덱 위 3장 확인',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < topCards.length; i++)
                ListTile(
                  dense: true,
                  leading: Text('${i + 1}위',
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  title: Text(topCards[i].def.nameKo ?? topCards[i].def.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                  subtitle: Text('${topCards[i].def.month}월',
                      style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 역순으로 재배치 (3→2→1)
                notifier.useKeenEyeReorder(
                    List.generate(topCards.length, (i) => topCards.length - 1 - i));
                ref.read(runStateNotifierProvider.notifier).consumeActiveSkill(skillId);
              },
              child: const Text('역순으로 바꾸기',
                  style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        ),
      );
    } else if (skillId == 'a_trick') {
      final hand = gameState.playerHand as List;
      if (field.isEmpty || hand.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('필드 또는 손패가 없습니다'), duration: Duration(seconds: 2)),
        );
        return;
      }
      // 바닥 카드 선택 → 손패 월로 변경
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          title: const Text('🃏 변경할 바닥 카드 선택',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          content: SizedBox(
            width: 200,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: field.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (_, fi) {
                final fCard = field[fi];
                return ListTile(
                  dense: true,
                  title: Text(fCard.def.nameKo ?? fCard.def.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                  subtitle: Text('${fCard.def.month}월 → 내 패 월로 변경',
                      style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  onTap: () {
                    Navigator.pop(context);
                    // 손패 중 가장 유리한 월(첫번째) 사용
                    final handMonths = hand
                        .where((c) => !c.def.isBonus && !c.isDeckDraw)
                        .map<int>((c) => c.def.month as int)
                        .toSet()
                        .toList();
                    if (handMonths.isNotEmpty) {
                      notifier.useTrickOnCards(fi, handMonths.first);
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      );
    }
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


