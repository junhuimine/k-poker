/// 🎴 K-Poker — 신규 상점 UI (3분류 아이템)
///
/// 1. 인게임 액티브 스킬 (장착 제한 없음, 소모품)
/// 2. 라운드 장착 (1회용, 시작 전 슬롯 장착)
/// 3. 영구 부적 (보유 시 자동 상시 적용)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/item_library.dart';
import '../models/run_state.dart';
import '../state/game_providers.dart';
import '../i18n/app_strings.dart';

class ShopScreen extends ConsumerWidget {
  final VoidCallback onClose;

  const ShopScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(runStateNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          // ── 상점 헤더 ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1A1A2E), Colors.black.withValues(alpha: 0.8)],
              ),
              border: const Border(bottom: BorderSide(color: Color(0xFF30363D))),
            ),
            child: Row(
              children: [
                const Text('🛒', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                const Text('비밀 상점', style: TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                // 골드 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text(
                    '🪙 ${run.gold} G',
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),

          // ── 상점 캐러셀 컨텐츠 ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('⚡ 인게임 액티브 스킬 (소모품)', '게임 중 턴을 소모하지 않고 원할 때 발동!'),
                  _buildHorizontalList(
                    items: shopActiveSkills,
                    itemBuilder: (context, item) => _buildActiveSkillCard(ref, run, item as ActiveSkill),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('🛡️ 라운드 장착 (일회성)', '이번 판 시작 전에 미리 장비! (판 종료 시 소멸)'),
                  _buildHorizontalList(
                    items: shopPreRoundItems,
                    itemBuilder: (context, item) => _buildPreRoundCard(ref, run, item as PreRoundItem),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('📜 영구 부적 (패시브)', '한 번 사두면 평생 자동 적용!'),
                  _buildHorizontalList(
                    items: shopPassiveTalismans,
                    itemBuilder: (context, item) => _buildPassiveCard(ref, run, item as PassiveTalisman),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── 하단 버튼 ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF30363D))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('쇼핑 종료 / 대기실로 →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHorizontalList({required List<BaseItemDef> items, required Widget Function(BuildContext, BaseItemDef) itemBuilder}) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      ),
    );
  }

  // 1. 액티브 스킬 (파란색 계열)
  Widget _buildActiveSkillCard(WidgetRef ref, RunState run, ActiveSkill item) {
    final count = run.inventorySkills[item.id] ?? 0;
    final canAfford = run.gold >= item.shopCost;
    final s = ref.watch(appStringsProvider);

    return _ItemCardImpl(
      item: item,
      s: s,
      themeColor: Colors.blueAccent,
      statusText: count > 0 ? '보유량: $count개' : null,
      onBuy: canAfford ? () => ref.read(runStateNotifierProvider.notifier).buyActiveSkill(item.id, item.shopCost) : null,
    );
  }

  // 2. 라운드 장착품 (초록색 계열)
  Widget _buildPreRoundCard(WidgetRef ref, RunState run, PreRoundItem item) {
    final count = run.inventoryRoundItems[item.id] ?? 0;
    final isEquipped = run.equippedRoundItemIds.contains(item.id);
    final canAfford = run.gold >= item.shopCost;
    final s = ref.watch(appStringsProvider);

    return _ItemCardImpl(
      item: item,
      s: s,
      themeColor: Colors.greenAccent,
      statusText: isEquipped ? '✅ 장착 완료' : (count > 0 ? '보유량: $count개' : null),
      onBuy: canAfford ? () => ref.read(runStateNotifierProvider.notifier).buyPreRoundItem(item.id, item.shopCost) : null,
      extraAction: (count > 0 && !isEquipped) ? () => ref.read(runStateNotifierProvider.notifier).equipRoundItem(item.id) : null,
      extraActionLabel: '장착하기',
    );
  }

  // 3. 영구 부적 (황금색 계열)
  Widget _buildPassiveCard(WidgetRef ref, RunState run, PassiveTalisman item) {
    final isOwned = run.ownedTalismanIds.contains(item.id);
    final canAfford = run.gold >= item.shopCost;
    final s = ref.watch(appStringsProvider);

    return _ItemCardImpl(
      item: item,
      s: s,
      themeColor: Colors.amber,
      statusText: isOwned ? '✅ 영구 보유 중' : null,
      onBuy: (!isOwned && canAfford) ? () => ref.read(runStateNotifierProvider.notifier).buyPassiveTalisman(item.id, item.shopCost) : null,
      overrideButtonText: isOwned ? '구매 완료' : null,
    );
  }
}

class _ItemCardImpl extends StatelessWidget {
  final BaseItemDef item;
  final AppStrings s;
  final Color themeColor;
  final String? statusText;
  final VoidCallback? onBuy;
  final VoidCallback? extraAction;
  final String? extraActionLabel;
  final String? overrideButtonText;

  const _ItemCardImpl({
    required this.item,
    required this.s,
    required this.themeColor,
    this.statusText,
    this.onBuy,
    this.extraAction,
    this.extraActionLabel,
    this.overrideButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 24)),
              const Spacer(),
              Text(item.id, style: TextStyle(color: themeColor.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(s.getItemName(item.id, item.nameKo), style: TextStyle(color: themeColor, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1),
          const SizedBox(height: 4),
          Expanded(
            child: Text(s.getItemDesc(item.id, item.description), style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3), maxLines: 5, overflow: TextOverflow.ellipsis),
          ),
          if (statusText != null) ...[
            const SizedBox(height: 4),
            Text(statusText!, style: TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 8),
          if (extraAction != null) ...[
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: extraAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor, foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(extraActionLabel ?? '사용', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 4),
          ],
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              onPressed: onBuy,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: onBuy == null ? Colors.white24 : themeColor),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                overrideButtonText ?? '${item.shopCost} G 구매',
                style: TextStyle(
                  color: onBuy == null ? Colors.white54 : themeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
