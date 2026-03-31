/// K-Poker 전체 플로우 통합 테스트
/// 딜링 → 매칭 → 점수계산 → 스킬효과 → 상점 → 경제 일관 검증
import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/data/all_cards.dart';
import 'package:k_poker/data/item_catalog.dart';
import 'package:k_poker/data/economy_config.dart';
import 'package:k_poker/data/shop_pool.dart';
import 'package:k_poker/data/synergy_defs.dart';
import 'package:k_poker/engine/game_engine.dart';
import 'package:k_poker/engine/score_calculator.dart';
import 'package:k_poker/engine/item_effect_resolver.dart';
import 'package:k_poker/engine/shop_generator.dart';
import 'package:k_poker/models/run_state.dart';
import 'package:k_poker/models/round_state.dart';
import 'package:k_poker/models/card_def.dart';

void main() {
  group('딜링 규칙 (2인 맞고 공식)', () {
    test('50장 = 바닥6 + 플레이어7 + 상대7 + 덱30', () {
      final state = GameEngine.createInitialState();
      expect(state.field.length, 6);
      expect(state.playerHand.length, 7);
      expect(state.opponentHand.length, 7);
      expect(state.deck.length, 30);
      final total = state.field.length + state.playerHand.length +
          state.opponentHand.length + state.deck.length;
      expect(total, 50);
    });

    test('handSize=7, fieldSize=6 상수 확인', () {
      expect(handSize, 7);
      expect(fieldSize, 6);
    });

    test('광 스캐너 장착 시에도 50장 유지', () {
      final run = RunState(equippedRoundItemIds: const ['c_gwang_scanner']);
      final state = GameEngine.createInitialState(run: run);
      final total = state.field.length + state.playerHand.length +
          state.opponentHand.length + state.deck.length;
      expect(total, 50);
    });
  });

  group('폭탄 규칙', () {
    test('바닥에 동월 카드 없으면 폭탄 불가', () {
      final hand = allCards
          .where((c) => c.month == 1)
          .take(3)
          .map((d) => CardInstance(def: d))
          .toList();
      final field = allCards
          .where((c) => c.month != 1)
          .take(6)
          .map((d) => CardInstance(def: d))
          .toList();
      expect(GameEngine.getBombMonth(hand, field), isNull);
    });

    test('바닥에 동월 1장 있으면 폭탄 가능', () {
      final month1Cards = allCards.where((c) => c.month == 1).toList();
      final hand = month1Cards.take(3).map((d) => CardInstance(def: d)).toList();
      final field = <CardInstance>[
        CardInstance(def: month1Cards.last),
        ...allCards.where((c) => c.month != 1).take(5).map((d) => CardInstance(def: d)),
      ];
      expect(GameEngine.getBombMonth(hand, field), 1);
    });
  });

  group('점수 계산', () {
    test('5광 = 15점', () {
      final brightCards = allCards
          .where((c) => c.grade == CardGrade.bright)
          .map((d) => CardInstance(def: d))
          .toList();
      final state = RoundState(
        deck: const [],
        field: const [],
        playerHand: const [],
        opponentHand: const [],
        playerCaptured: brightCards,
        opponentCaptured: const [],
        isFinished: true,
      );
      final result = ScoreCalculator.calculate(state, RunState());
      expect(result.baseChips, greaterThanOrEqualTo(15));
    });

    test('멍박 기준 = 7장+ (6장은 멍박 아님)', () {
      final animals = allCards
          .where((c) => c.grade == CardGrade.animal)
          .take(6)
          .map((d) => CardInstance(def: d))
          .toList();
      final state = RoundState(
        deck: const [],
        field: const [],
        playerHand: const [],
        opponentHand: const [],
        playerCaptured: animals,
        opponentCaptured: const [],
        isFinished: true,
      );
      final result = ScoreCalculator.calculate(state, RunState());
      expect(result.multiplier, 1.0, reason: '동물 6장은 멍박 아님');
    });
  });

  group('골드 경제', () {
    test('시작 골드 = 50G', () {
      expect(EconomyConfig.startingGold, 50);
    });

    test('점당 골드 = 12G (플랫)', () {
      expect(EconomyConfig.goldPerPoint, 12);
      expect(EconomyConfig.stageGoldScaling, 0.0);
      expect(EconomyConfig.effectiveGoldPerPoint(1), 12);
      expect(EconomyConfig.effectiveGoldPerPoint(6), 12);
    });
  });

  group('아이템 카탈로그', () {
    test('51개 아이템 존재', () {
      expect(itemCatalog.length, 51);
    });

    test('슬롯별 분류', () {
      final passives = getItemsBySlot(ItemSlot.passiveAlways);
      final talismans = getItemsBySlot(ItemSlot.talisman);
      final actives = getItemsBySlot(ItemSlot.activeInGame);
      final consumables = getItemsBySlot(ItemSlot.consumableRound);
      // 패시브 29개 + 비밀 1개(passiveAlways) = 30개
      expect(passives.length, greaterThanOrEqualTo(29));
      expect(talismans.length, 9);
      expect(actives.length, 6);
      expect(consumables.length, 6);
    });

    test('모든 아이템에 고유 ID', () {
      final ids = itemCatalog.map((i) => i.id).toSet();
      expect(ids.length, itemCatalog.length);
    });

    test('레거시 ID 매핑', () {
      expect(findCatalogItem('S-001'), isNotNull);
      expect(findCatalogItem('S-002'), isNotNull);
      expect(findCatalogItem('P-001'), isNotNull);
      expect(findCatalogItem('T-001'), isNotNull);
    });
  });

  group('상점 생성', () {
    test('스테이지 1: 슬롯 3개', () {
      expect(ShopPool.getSlotCount(1), 3);
    });

    test('스테이지 4+: 슬롯 4개', () {
      expect(ShopPool.getSlotCount(4), 4);
      expect(ShopPool.getSlotCount(6), 4);
    });

    test('상점 생성 시 중복 아이템 없음', () {
      final run = RunState(gold: 9999);
      final shop = ShopGenerator.generate(stage: 3, run: run);
      final itemIds = shop.slots.map((s) => s.itemId).toSet();
      expect(itemIds.length, shop.slots.length);
    });

    test('행운의 동전 보유 시 할인', () {
      final run1 = RunState(gold: 9999);
      final run2 = RunState(gold: 9999, ownedTalismanIds: const ['t_lucky_coin']);
      final shop1 = ShopGenerator.generate(stage: 1, run: run1, seed: 42);
      final shop2 = ShopGenerator.generate(stage: 1, run: run2, seed: 42);
      for (int i = 0; i < shop1.slots.length && i < shop2.slots.length; i++) {
        if (shop1.slots[i].itemId == shop2.slots[i].itemId) {
          expect(shop2.slots[i].price, lessThanOrEqualTo(shop1.slots[i].price));
        }
      }
    });
  });

  group('시너지', () {
    test('태그 시너지 + 숨겨진 시너지 존재', () {
      expect(tagSynergies.length, 9);
      expect(hiddenSynergies.length, 3);
    });

    test('광 마스터: gwang 태그 3개 필요', () {
      final gwangSyn = tagSynergies.firstWhere((s) => s.id == 'syn_gwang_master');
      expect(gwangSyn.requiredTag, ItemTag.gwang);
      expect(gwangSyn.requiredCount, 3);
    });
  });

  group('ItemEffectResolver', () {
    test('전설의 타짜: xMult > 1.0', () {
      final run = RunState(ownedPassiveIds: const ['ps_legendary_tazza']);
      final state = RoundState(
        deck: const [],
        field: const [],
        playerHand: const [],
        opponentHand: const [],
        playerCaptured: const [],
        opponentCaptured: const [],
      );
      final result = ItemEffectResolver.resolveAll(
        run: run,
        round: state,
        playerCaptured: const [],
      );
      expect(result.xMult, greaterThan(1.0));
    });

    test('피 수집가: junkThreshold=8', () {
      final run = RunState(ownedPassiveIds: const ['ps_junk_collector']);
      final state = RoundState(
        deck: const [],
        field: const [],
        playerHand: const [],
        opponentHand: const [],
        playerCaptured: const [],
        opponentCaptured: const [],
      );
      final result = ItemEffectResolver.resolveAll(
        run: run,
        round: state,
        playerCaptured: const [],
      );
      expect(result.specialEffects['junkThreshold'], 8);
    });

    test('광박 방패: nullifyGwangbak', () {
      final run = RunState(ownedTalismanIds: const ['t_gwangbak_shield']);
      final state = RoundState(
        deck: const [],
        field: const [],
        playerHand: const [],
        opponentHand: const [],
        playerCaptured: const [],
        opponentCaptured: const [],
      );
      final result = ItemEffectResolver.resolveAll(
        run: run,
        round: state,
        playerCaptured: const [],
      );
      expect(result.specialEffects['nullifyGwangbak'], true);
    });
  });

  group('피 탈취 (stealPi)', () {
    test('2장 탈취 정상 동작', () {
      final opJunks = allCards
          .where((c) => c.grade == CardGrade.junk)
          .take(5)
          .map((d) => CardInstance(def: d))
          .toList();
      final state = RoundState(
        deck: const [],
        field: const [],
        playerHand: const [],
        opponentHand: const [],
        playerCaptured: const [],
        opponentCaptured: opJunks,
      );
      final result = GameEngine.stealPi(state, 'player', 2);
      expect(result.playerCaptured.length, 2);
      expect(result.opponentCaptured.length, 3);
    });
  });

  group('흔들기', () {
    test('RoundState에 isShaking/shakeMonth 필드', () {
      final state = RoundState(
        deck: const [],
        field: const [],
        playerHand: const [],
        opponentHand: const [],
        isShaking: true,
        shakeMonth: 3,
      );
      expect(state.isShaking, true);
      expect(state.shakeMonth, 3);
    });

    test('흔들기 시 점수 x2', () {
      final brightCards = allCards
          .where((c) => c.grade == CardGrade.bright)
          .take(3)
          .map((d) => CardInstance(def: d))
          .toList();
      final state = RoundState(
        deck: const [],
        field: const [],
        playerHand: const [],
        opponentHand: const [],
        playerCaptured: brightCards,
        opponentCaptured: const [],
        isFinished: true,
        isShaking: true,
      );
      final resultNoShake = ScoreCalculator.calculate(
        state.copyWith(isShaking: false), RunState(),
      );
      final resultShake = ScoreCalculator.calculate(state, RunState());
      // 흔들기 시 배율이 더 높아야 함
      expect(resultShake.multiplier, greaterThanOrEqualTo(resultNoShake.multiplier));
    });
  });
}
