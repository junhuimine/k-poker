/// K-Poker -- 상점 슬롯 생성기 (로그라이크)
///
/// 스테이지별 희귀도 가중치 기반으로 랜덤 상점 슬롯 생성.
/// 리롤, 비밀 해금, 중복 방지, 할인 처리.
library;

import 'dart:math';
import '../data/economy_config.dart';
import '../data/item_catalog.dart';
import '../data/shop_pool.dart';
import '../models/run_state.dart';
import '../models/shop_state.dart';

class ShopGenerator {
  /// 상점 슬롯 생성
  static ShopState generate({
    required int stage,
    required RunState run,
    int? seed,
  }) {
    final rng = Random(seed ?? DateTime.now().microsecondsSinceEpoch);
    final weights = ShopPool.getRarityWeights(stage);
    final slotCount = ShopPool.getSlotCount(stage);

    // 이미 보유 중인 부적 ID (중복 구매 방지)
    final ownedTalismanSet = run.ownedTalismanIds.toSet();
    // 이미 보유 중인 패시브 ID (중복 구매 방지)
    final ownedPassiveSet = run.ownedPassiveIds.toSet();

    // t_lucky_coin 보유 시 20% 할인
    final hasLuckyCoin = run.ownedTalismanIds.contains('t_lucky_coin');
    // 재벌 시너지 보유 시 추가 10% 할인
    final economyTagCount = _countEconomyTags(run.allOwnedItemIds);
    final hasTycoonSynergy = economyTagCount >= 3;
    final discountRate = (hasLuckyCoin ? 0.20 : 0.0) + (hasTycoonSynergy ? 0.10 : 0.0);

    final List<ShopSlot> slots = [];
    final Set<String> selectedIds = {};

    for (int i = 0; i < slotCount; i++) {
      final item = _rollItem(
        rng: rng,
        weights: weights,
        excludeIds: selectedIds,
        ownedTalismanIds: ownedTalismanSet,
        ownedPassiveIds: ownedPassiveSet,
        allowSecret: false,
      );
      if (item != null) {
        selectedIds.add(item.id);
        final price = _applyDiscount(item.baseCost, discountRate);
        slots.add(ShopSlot(itemId: item.id, price: price));
      }
    }

    // 비밀 아이템 해금 체크 -> 추가 슬롯
    final unlockedSecrets = ShopPool.getUnlockedSecretIds(run);
    final availableSecrets = unlockedSecrets
        .where((id) => !ownedPassiveSet.contains(id) && !selectedIds.contains(id))
        .toList();

    if (availableSecrets.isNotEmpty && rng.nextDouble() < 0.5) {
      final secretId = availableSecrets[rng.nextInt(availableSecrets.length)];
      final secretItem = findCatalogItem(secretId);
      if (secretItem != null) {
        final price = _applyDiscount(secretItem.baseCost, discountRate);
        slots.add(ShopSlot(itemId: secretId, price: price));
      }
    }

    // 잠긴 비밀 아이템 힌트 (해금 안 된 것)
    final lockedSecrets = itemCatalog
        .where((i) => i.rarity == Rarity.secret)
        .map((i) => i.id)
        .where((id) => !unlockedSecrets.contains(id) && !ownedPassiveSet.contains(id))
        .toList();
    if (lockedSecrets.isNotEmpty && rng.nextDouble() < 0.3) {
      final lockedId = lockedSecrets[rng.nextInt(lockedSecrets.length)];
      slots.add(ShopSlot(itemId: lockedId, price: 0, locked: true));
    }

    return ShopState(
      slots: slots,
      rerollCount: 0,
      rerollCost: EconomyConfig.baseRerollCost,
      unlockedSecretIds: unlockedSecrets,
    );
  }

  /// 리롤
  static ShopState reroll({
    required ShopState current,
    required int stage,
    required RunState run,
  }) {
    final newShop = generate(stage: stage, run: run);
    return newShop.copyWith(
      rerollCount: current.rerollCount + 1,
      rerollCost: current.rerollCost + EconomyConfig.rerollCostIncrement,
    );
  }

  /// 가중치 기반 희귀도 롤
  static Rarity _rollRarity(Random rng, Map<Rarity, double> weights) {
    final roll = rng.nextDouble();
    double cumulative = 0.0;
    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (roll < cumulative) return entry.key;
    }
    return Rarity.common;
  }

  /// 아이템 롤 (중복 방지 + 부적/패시브 보유 제외)
  static ItemDef? _rollItem({
    required Random rng,
    required Map<Rarity, double> weights,
    required Set<String> excludeIds,
    required Set<String> ownedTalismanIds,
    required Set<String> ownedPassiveIds,
    required bool allowSecret,
  }) {
    // 최대 20회 재시도
    for (int attempt = 0; attempt < 20; attempt++) {
      final rarity = _rollRarity(rng, weights);

      // Secret은 별도 로직으로 처리
      if (rarity == Rarity.secret && !allowSecret) continue;

      final pool = itemCatalog.where((item) {
        if (item.rarity != rarity) return false;
        if (item.rarity == Rarity.secret) return false; // Secret 별도
        if (excludeIds.contains(item.id)) return false;
        // 부적 중복 제외
        if (item.slot == ItemSlot.talisman && ownedTalismanIds.contains(item.id)) {
          return false;
        }
        // 패시브 중복 제외
        if (item.slot == ItemSlot.passiveAlways && ownedPassiveIds.contains(item.id)) {
          return false;
        }
        return true;
      }).toList();

      if (pool.isNotEmpty) {
        return pool[rng.nextInt(pool.length)];
      }
    }
    return null;
  }

  /// 할인 적용
  static int _applyDiscount(int baseCost, double discountRate) {
    if (discountRate <= 0) return baseCost;
    return (baseCost * (1.0 - discountRate)).round();
  }

  /// 경제 태그 보유 수 카운트 (시너지 판정용)
  static int _countEconomyTags(List<String> ownedItemIds) {
    int count = 0;
    for (final id in ownedItemIds) {
      final item = findCatalogItem(id);
      if (item != null && item.tags.contains(ItemTag.economy)) {
        count++;
      }
    }
    return count;
  }
}
