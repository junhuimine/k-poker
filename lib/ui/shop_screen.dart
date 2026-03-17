/// 🎴 K-Poker — 상점 UI
///
/// 기술/부적 구매, 카드 강화

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/skills.dart';
import '../data/stage_config.dart';
import '../state/game_providers.dart';

class ShopScreen extends ConsumerWidget {
  final VoidCallback onClose;

  const ShopScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(runStateNotifierProvider);
    final currency = getCurrencyForLocale(run.currencyLocale);

    // 스테이지에 따라 상점 아이템 필터링
    final availableSkills = _getAvailableSkills(run.stage, run.activeSkillIds);
    final availableTalismans = _getAvailableTalismans(run.activeTalismanIds);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          // 상점 헤더
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
                const Text('타짜 상점', style: TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                // 소지금 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    '💰 ${currency.formatExact(run.money)}',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
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

          // 상점 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 기술 섹션 ──
                  const Text('🃏 타짜 기술', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('장착 중: ${run.activeSkillIds.length}/5', style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableSkills.map((skill) => _buildSkillCard(
                      ref, skill, currency, run,
                    )).toList(),
                  ),

                  const SizedBox(height: 32),

                  // ── 부적 섹션 ──
                  const Text('🧿 부적', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('장착 중: ${run.activeTalismanIds.length}/3', style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableTalismans.map((t) => _buildTalismanCard(
                      ref, t, currency, run,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),

          // 하단: 다음 라운드 버튼
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
                child: const Text('다음 라운드 →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(WidgetRef ref, SkillDef skill, CurrencyConfig currency, dynamic run) {
    final isOwned = run.activeSkillIds.contains(skill.id);
    final canAfford = run.money >= skill.shopCost * currency.pointValue * 10;
    final isFull = run.activeSkillIds.length >= 5;

    Color borderColor;
    Color bgColor;
    switch (skill.rarity) {
      case SkillRarity.common:
        borderColor = Colors.green; bgColor = Colors.green.withValues(alpha: 0.1);
      case SkillRarity.rare:
        borderColor = Colors.blue; bgColor = Colors.blue.withValues(alpha: 0.1);
      case SkillRarity.epic:
        borderColor = Colors.purple; bgColor = Colors.purple.withValues(alpha: 0.1);
      case SkillRarity.legendary:
        borderColor = const Color(0xFFFFD700); bgColor = const Color(0xFFFFD700).withValues(alpha: 0.1);
    }

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwned ? borderColor.withValues(alpha: 0.2) : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOwned ? borderColor : borderColor.withValues(alpha: 0.5), width: isOwned ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(skill.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Expanded(child: Text(skill.nameKo, style: TextStyle(color: borderColor, fontSize: 14, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 4),
          Text(skill.description, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 8),
          if (isOwned)
            const Text('✅ 장착됨', style: TextStyle(color: Colors.greenAccent, fontSize: 12))
          else
            ElevatedButton(
              onPressed: (canAfford && !isFull) ? () {
                final cost = skill.shopCost * currency.pointValue * 10;
                ref.read(runStateNotifierProvider.notifier).buySkill(skill.id, cost);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor, foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                currency.formatAmount(skill.shopCost * currency.pointValue * 10),
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTalismanCard(WidgetRef ref, Talisman talisman, CurrencyConfig currency, dynamic run) {
    final isOwned = run.activeTalismanIds.contains(talisman.id);
    final canAfford = run.money >= talisman.shopCost * currency.pointValue * 10;
    final isFull = run.activeTalismanIds.length >= 3;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwned ? Colors.amber.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOwned ? Colors.amber : Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(talisman.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Expanded(child: Text(talisman.nameKo, style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 4),
          Text(talisman.description, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 8),
          if (isOwned)
            const Text('✅ 장착됨', style: TextStyle(color: Colors.greenAccent, fontSize: 12))
          else
            ElevatedButton(
              onPressed: (canAfford && !isFull) ? () {
                final cost = talisman.shopCost * currency.pointValue * 10;
                ref.read(runStateNotifierProvider.notifier).buyTalisman(talisman.id, cost);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                currency.formatAmount(talisman.shopCost * currency.pointValue * 10),
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  List<SkillDef> _getAvailableSkills(int stage, List<String> owned) {
    // 스테이지에 따라 등급 필터링
    return allSkills.where((s) {
      if (owned.contains(s.id)) return true; // 이미 소유한 건 항상 표시
      switch (s.rarity) {
        case SkillRarity.common: return true;
        case SkillRarity.rare: return stage >= 2;
        case SkillRarity.epic: return stage >= 3;
        case SkillRarity.legendary: return stage >= 5;
      }
    }).toList();
  }

  List<Talisman> _getAvailableTalismans(List<String> owned) {
    return allTalismans;
  }
}
