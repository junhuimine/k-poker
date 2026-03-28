/// K-Poker -- 카드/아이템 데이터 무결성 테스트
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/data/all_cards.dart';
import 'package:k_poker/data/item_catalog.dart';
import 'package:k_poker/models/card_def.dart';

void main() {
  group('카드 데이터 무결성', () {
    test('총 50장 (48 + 보너스 2)', () {
      expect(allCards.length, 50);
      expect(totalCards, 50);
    });

    test('보너스 카드 2장', () {
      final bonuses = allCards.where((c) => c.isBonus).toList();
      expect(bonuses.length, 2);
    });

    test('광 카드 정확히 5장', () {
      final brights = getBrightCards();
      expect(brights.length, 5);
      // 1월, 3월, 8월, 11월, 12월
      final months = brights.map((c) => c.month).toSet();
      expect(months, {1, 3, 8, 11, 12});
    });

    test('고도리 새 카드 정확히 3장 (2,4,8월)', () {
      final birds = getBirdCards();
      expect(birds.length, 3);
      final months = birds.map((c) => c.month).toSet();
      expect(months, {2, 4, 8});
    });

    test('홍단 카드 정확히 3장 (1,2,3월)', () {
      final reds = getRedRibbonCards();
      expect(reds.length, 3);
      final months = reds.map((c) => c.month).toSet();
      expect(months, {1, 2, 3});
    });

    test('청단 카드 정확히 3장 (6,9,10월)', () {
      final blues = getBlueRibbonCards();
      expect(blues.length, 3);
      final months = blues.map((c) => c.month).toSet();
      expect(months, {6, 9, 10});
    });

    test('초단 카드 정확히 3장 (4,5,7월)', () {
      final grasses = getGrassRibbonCards();
      expect(grasses.length, 3);
      final months = grasses.map((c) => c.month).toSet();
      expect(months, {4, 5, 7});
    });

    test('각 월(1~12) 정확히 4장씩', () {
      for (int m = 1; m <= 12; m++) {
        final cards = getCardsByMonth(m);
        expect(cards.length, 4, reason: '$m월 카드가 4장이어야 함');
      }
    });

    test('모든 카드 ID 유일', () {
      final ids = allCards.map((c) => c.id).toSet();
      expect(ids.length, allCards.length);
    });

    test('모든 카드에 nameKo 존재', () {
      for (final card in allCards) {
        expect(card.nameKo.isNotEmpty, isTrue, reason: '${card.id}의 nameKo 비어있음');
      }
    });

    test('모든 카드에 name(영어) 존재', () {
      for (final card in allCards) {
        expect(card.name.isNotEmpty, isTrue, reason: '${card.id}의 name 비어있음');
      }
    });

    test('쌍피 카드에 doubleJunk = true', () {
      final doubleJunks = allCards.where((c) => c.doubleJunk).toList();
      // 9월 술잔, 11월 쌍피, 12월 쌍피, 보너스 2장 = 5장
      expect(doubleJunks.length, 5);
    });

    test('국화 술잔(m09_double) 양용 속성', () {
      final cup = allCards.firstWhere((c) => c.id == 'm09_double');
      expect(cup.grade, CardGrade.animal);
      expect(cup.doubleJunk, isTrue);
      expect(cup.month, 9);
    });
  });

  group('아이템 카탈로그 무결성', () {
    test('전체 아이템 51개', () {
      expect(itemCatalog.length, 51);
    });

    test('슬롯별 분포: 패시브 29, 부적 9, 액티브 6, 소모품 6, 비밀 1(패시브)', () {
      expect(getItemsBySlot(ItemSlot.passiveAlways).length, 30); // 29 + 비밀 1
      expect(getItemsBySlot(ItemSlot.talisman).length, 9);
      expect(getItemsBySlot(ItemSlot.activeInGame).length, 6);
      expect(getItemsBySlot(ItemSlot.consumableRound).length, 6);
    });

    test('아이템 ID 유일', () {
      final ids = itemCatalog.map((i) => i.id).toSet();
      expect(ids.length, itemCatalog.length);
    });

    test('모든 아이템에 nameKo 존재', () {
      for (final item in itemCatalog) {
        expect(item.nameKo.isNotEmpty, isTrue, reason: '${item.id}의 nameKo 비어있음');
      }
    });

    test('모든 아이템에 baseCost > 0', () {
      for (final item in itemCatalog) {
        expect(item.baseCost, greaterThan(0), reason: '${item.id}의 baseCost <= 0');
      }
    });

    test('findCatalogItem -- 모든 아이템 검색 가능', () {
      for (final item in itemCatalog) {
        final found = findCatalogItem(item.id);
        expect(found, isNotNull, reason: '${item.id} 검색 실패');
        expect(found!.nameKo, item.nameKo);
      }
    });

    test('findCatalogItem -- 없는 ID는 null', () {
      expect(findCatalogItem('nonexistent'), isNull);
    });

    test('findCatalogItem -- 레거시 ID 호환', () {
      // P-001 -> c_gwang_scanner
      final found = findCatalogItem('P-001');
      expect(found, isNotNull);
      expect(found!.id, 'c_gwang_scanner');
    });
  });
}
