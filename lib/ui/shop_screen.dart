/// K-Poker -- 로그라이크 상점 UI (슬롯 기반)
///
/// ShopGenerator가 생성한 랜덤 슬롯을 표시.
/// 리롤, 시너지 현황, 보유 아이템 요약 포함.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/item_catalog.dart';
import '../data/synergy_defs.dart';
import '../models/shop_state.dart';
import '../state/game_providers.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_provider.dart';

class ShopScreen extends ConsumerWidget {
  final VoidCallback onClose;

  const ShopScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(runStateNotifierProvider);
    final s = ref.watch(appStringsProvider);
    final shopState = run.shopState;

    // 시너지 계산
    final activeSynergies = getActiveTagSynergies(run.allOwnedItemIds);
    const allTagSynergies = tagSynergies;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          // -- 상점 헤더 --
          _buildHeader(run, s),

          // -- 메인 컨텐츠 --
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 랜덤 슬롯
                  if (shopState.slots.isNotEmpty) ...[
                    _buildSectionTitle(s.ui('shopSecretShop'), s.shopStage(run.stage)),
                    const SizedBox(height: 8),
                    _buildSlotGrid(ref, run, shopState, s),
                    const SizedBox(height: 16),

                    // 리롤 버튼
                    _buildRerollButton(ref, run, shopState, s),
                    const SizedBox(height: 24),
                  ],

                  // 시너지 현황
                  _buildSynergySection(run, activeSynergies, allTagSynergies, s),
                  const SizedBox(height: 24),

                  // 보유 아이템 요약
                  _buildInventorySection(ref, run, s),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // -- 하단: 계속 진행 --
          _buildFooter(s),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  //  헤더
  // ═══════════════════════════════════════

  Widget _buildHeader(dynamic run, AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1A2E), Colors.black.withValues(alpha: 0.8)],
        ),
        border: const Border(bottom: BorderSide(color: Color(0xFF30363D))),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 좁은 화면에서는 타이틀 폰트/패딩 축소
            final isNarrow = constraints.maxWidth < 380;
            final titleFont = isNarrow ? 17.0 : 22.0;
            final chipFont = isNarrow ? 11.0 : 13.0;
            final goldFont = isNarrow ? 13.0 : 15.0;

            return Row(
              children: [
                Text('🏪', style: TextStyle(fontSize: isNarrow ? 22 : 28)),
                SizedBox(width: isNarrow ? 6 : 12),
                // 타이틀 — Flexible + ellipsis로 오버플로우 방지
                Flexible(
                  child: Text(
                    s.ui('shopSecretShop'),
                    style: TextStyle(
                      color: const Color(0xFFFFD700),
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: isNarrow ? 6 : 12),
                // Stage 표시
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isNarrow ? 6 : 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.shopStage(run.stage),
                    style: TextStyle(color: Colors.white70, fontSize: chipFont),
                  ),
                ),
                SizedBox(width: isNarrow ? 4 : 8),
                // 골드 표시 — FittedBox로 큰 숫자도 축소 처리
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isNarrow ? 10 : 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  constraints: BoxConstraints(maxWidth: isNarrow ? 100 : 140),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '🪙 ${run.gold} G',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: goldFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  섹션 타이틀
  // ═══════════════════════════════════════

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  //  슬롯 그리드
  // ═══════════════════════════════════════

  Widget _buildSlotGrid(WidgetRef ref, dynamic run, ShopState shopState, AppStrings s) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 폭에 따라 카드 크기 조정 (모바일 좁은 화면 대응)
        final isNarrow = constraints.maxWidth < 380;
        final cardHeight = isNarrow ? 220.0 : 240.0;
        return SizedBox(
          height: cardHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: shopState.slots.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final slot = shopState.slots[index];
              final item = findCatalogItem(slot.itemId);
              if (item == null) return const SizedBox.shrink();
              return _buildSlotCard(ref, run, slot, item, index, s, isNarrow: isNarrow);
            },
          ),
        );
      },
    );
  }

  Widget _buildSlotCard(
    WidgetRef ref,
    dynamic run,
    ShopSlot slot,
    ItemDef item,
    int index,
    AppStrings s, {
    bool isNarrow = false,
  }) {
    final borderColor = _rarityBorderColor(item.rarity);
    final canAfford = run.gold >= slot.price;
    final isLocked = slot.locked;
    final isSold = slot.sold;

    return Container(
      width: isNarrow ? 150 : 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSold
            ? Colors.grey.withValues(alpha: 0.1)
            : borderColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSold ? Colors.grey.withValues(alpha: 0.3) : borderColor.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 이모지 + 레어리티 뱃지
          Row(
            children: [
              if (isLocked)
                const Text('🔒', style: TextStyle(fontSize: 28))
              else
                Text(item.emoji, style: const TextStyle(fontSize: 28)),
              const Spacer(),
              _buildRarityBadge(item.rarity),
            ],
          ),
          const SizedBox(height: 6),

          // 이름
          Text(
            isLocked ? '???' : s.getItemName(item.id, item.nameKo),
            style: TextStyle(
              color: isSold ? Colors.grey : borderColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // 설명
          Expanded(
            child: Text(
              isLocked
                  ? _getUnlockHint(item.id, s)
                  : s.getItemDesc(item.id, item.descKo),
              style: TextStyle(
                color: isSold ? Colors.grey.withValues(alpha: 0.5) : Colors.white70,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 6),

          // 슬롯 타입 태그
          if (!isLocked && !isSold)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildSlotTypeBadge(item.slot, s),
            ),

          // 구매 버튼 / SOLD OUT / 잠김
          SizedBox(
            width: double.infinity,
            height: 34,
            child: isSold
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.ui('shopSoldOut'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : isLocked
                    ? Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          s.ui('shopLocked'),
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: canAfford
                            ? () => ref.read(runStateNotifierProvider.notifier).buyShopItem(index)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? borderColor : Colors.grey.withValues(alpha: 0.2),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.grey.withValues(alpha: 0.15),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '🪙 ${slot.price} G',
                            style: TextStyle(
                              color: canAfford ? Colors.black : Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  //  리롤 버튼
  // ═══════════════════════════════════════

  Widget _buildRerollButton(WidgetRef ref, dynamic run, ShopState shopState, AppStrings s) {
    final canAfford = run.gold >= shopState.rerollCost;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton.icon(
          onPressed: canAfford
              ? () => ref.read(runStateNotifierProvider.notifier).rerollShop(run.stage)
              : null,
          icon: const Text('🔄', style: TextStyle(fontSize: 18)),
          label: Text(
            s.shopReroll(shopState.rerollCost),
            style: TextStyle(
              color: canAfford ? Colors.amberAccent : Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: canAfford ? Colors.amberAccent.withValues(alpha: 0.6) : Colors.grey.withValues(alpha: 0.3),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  시너지 섹션
  // ═══════════════════════════════════════

  Widget _buildSynergySection(
    dynamic run,
    List<SynergyDef> activeSynergies,
    List<SynergyDef> allSynergies,
    AppStrings s,
  ) {
    final activeIds = activeSynergies.map((syn) => syn.id).toSet();

    // 보유 아이템의 태그 카운트
    final Map<ItemTag, int> tagCounts = {};
    for (final id in run.allOwnedItemIds) {
      final item = findCatalogItem(id);
      if (item == null) continue;
      for (final tag in item.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.ui('shopSynergyTitle'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...allSynergies.map((syn) {
            final isActive = activeIds.contains(syn.id);
            final current = tagCounts[syn.requiredTag] ?? 0;
            final required = syn.requiredCount;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    isActive ? '✅' : '🔲',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${s.getSynergyName(syn.id, syn.nameKo)} ($current/$required)',
                      style: TextStyle(
                        color: isActive ? Colors.greenAccent : Colors.white38,
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isActive)
                    Text(
                      _synergyEffectText(syn, s),
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _synergyEffectText(SynergyDef syn, AppStrings s) {
    final parts = <String>[];
    if (syn.bonusChips > 0) parts.add('+${syn.bonusChips} chips');
    if (syn.bonusMult > 0) parts.add('+${syn.bonusMult.toStringAsFixed(1)} mult');
    if (syn.bonusXMult != 1.0) parts.add('x${syn.bonusXMult.toStringAsFixed(1)}');
    if (parts.isEmpty) {
      final desc = s.getSynergyDesc(syn.id, syn.descKo);
      return desc.length > 15 ? '${desc.substring(0, 15)}...' : desc;
    }
    return parts.join(' ');
  }

  // ═══════════════════════════════════════
  //  보유 아이템 요약
  // ═══════════════════════════════════════

  Widget _buildInventorySection(WidgetRef ref, dynamic run, AppStrings s) {
    final passiveNames = run.ownedPassiveIds
        .map((String id) => findCatalogItem(id))
        .where((ItemDef? i) => i != null)
        .map((ItemDef? i) => '${i!.emoji} ${s.getItemName(i.id, i.nameKo)}')
        .toList();

    final talismanNames = run.ownedTalismanIds
        .map((String id) => findCatalogItem(id))
        .where((ItemDef? i) => i != null)
        .map((ItemDef? i) => '${i!.emoji} ${s.getItemName(i.id, i.nameKo)}')
        .toList();

    final activeEntries = <String>[];
    for (final entry in (run.inventorySkills as Map<String, int>).entries) {
      if (entry.value > 0) {
        final item = findCatalogItem(entry.key);
        if (item != null) {
          activeEntries.add('${item.emoji} ${s.getItemName(item.id, item.nameKo)} x${entry.value}');
        }
      }
    }

    // 소모품: Map<String, int> 형태로 수집 (장착 UI를 위해 별도 처리)
    final consumableItems = <String, int>{};
    for (final entry in (run.inventoryRoundItems as Map<String, int>).entries) {
      if (entry.value > 0) {
        consumableItems[entry.key] = entry.value;
      }
    }
    final equippedIds = run.equippedRoundItemIds as List<String>;

    final consumableEntries = <String>[];
    for (final entry in consumableItems.entries) {
      final item = findCatalogItem(entry.key);
      if (item != null) {
        consumableEntries.add('${item.emoji} ${s.getItemName(item.id, item.nameKo)} x${entry.value}');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.ui('shopInventoryTitle'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (passiveNames.isNotEmpty)
              _buildInventoryRow(
                '🔮',
                s.ui('shopPassiveTitle').replaceAll(RegExp(r'^[^\s]+\s'), ''),
                passiveNames.join(', '),
                Colors.purpleAccent,
              ),
            if (talismanNames.isNotEmpty)
              _buildInventoryRow(
                '📜',
                s.ui('shopTalismanTitle').replaceAll(RegExp(r'^[^\s]+\s'), ''),
                talismanNames.join(', '),
                Colors.amber,
              ),
            if (activeEntries.isNotEmpty)
              _buildInventoryRow(
                '⚡',
                s.ui('shopActiveSkillTitle').replaceAll(RegExp(r'^[^\s]+\s'), ''),
                activeEntries.join(', '),
                Colors.blueAccent,
              ),
            if (consumableEntries.isNotEmpty) ...[
              _buildInventoryRow(
                '🛡️',
                s.ui('shopPreRoundTitle').replaceAll(RegExp(r'^[^\s]+\s'), ''),
                consumableEntries.join(', '),
                Colors.greenAccent,
              ),
              const SizedBox(height: 8),
              // 소모품 장착 토글 버튼들
              ..._buildEquipButtons(ref, consumableItems, equippedIds, s),
            ],
            if (passiveNames.isEmpty &&
                talismanNames.isEmpty &&
                activeEntries.isEmpty &&
                consumableEntries.isEmpty)
              Text(
                s.ui('none'),
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEquipButtons(
    WidgetRef ref,
    Map<String, int> consumableItems,
    List<String> equippedIds,
    AppStrings s,
  ) {
    final widgets = <Widget>[];
    for (final entry in consumableItems.entries) {
      final itemId = entry.key;
      final item = findCatalogItem(itemId);
      if (item == null) continue;
      final isEquipped = equippedIds.contains(itemId);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.getItemName(itemId, item.nameKo),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 28,
                child: isEquipped
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.greenAccent),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.ui('shopEquipped'),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          ref.read(runStateNotifierProvider.notifier).equipRoundItem(itemId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          s.ui('shopEquip'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildInventoryRow(String emoji, String label, String items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: items,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  //  하단 (계속 진행)
  // ═══════════════════════════════════════

  Widget _buildFooter(AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF30363D))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              s.ui('shopExit'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  헬퍼
  // ═══════════════════════════════════════

  Color _rarityBorderColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return Colors.grey;
      case Rarity.rare:
        return Colors.blueAccent;
      case Rarity.epic:
        return Colors.purpleAccent;
      case Rarity.legendary:
        return const Color(0xFFFFD700);
      case Rarity.secret:
        return Colors.redAccent;
    }
  }

  Widget _buildRarityBadge(Rarity rarity) {
    final Color color = _rarityBorderColor(rarity);
    final String label;
    switch (rarity) {
      case Rarity.common:
        label = 'C';
      case Rarity.rare:
        label = 'R';
      case Rarity.epic:
        label = 'E';
      case Rarity.legendary:
        label = 'L';
      case Rarity.secret:
        label = 'S';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSlotTypeBadge(ItemSlot slot, AppStrings s) {
    final String label;
    final Color color;
    switch (slot) {
      case ItemSlot.activeInGame:
        label = s.ui('shopSlotActive');
        color = Colors.blueAccent;
      case ItemSlot.passiveAlways:
        label = s.ui('shopSlotPassive');
        color = Colors.purpleAccent;
      case ItemSlot.talisman:
        label = s.ui('shopSlotTalisman');
        color = Colors.amber;
      case ItemSlot.consumableRound:
        label = s.ui('shopSlotConsumable');
        color = Colors.greenAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getUnlockHint(String itemId, AppStrings s) {
    switch (itemId) {
      case 'x_ogwang_crown':
        return s.ui('unlockFiveBrights');
      default:
        return '???';
    }
  }
}
