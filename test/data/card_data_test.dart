/// K-Poker -- 카드/스킬/아이템 데이터 무결성 테스트
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/data/all_cards.dart';
import 'package:k_poker/data/skills.dart';
import 'package:k_poker/data/item_library.dart';
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

  group('스킬 데이터 무결성', () {
    test('전체 스킬 32개', () {
      expect(allSkills.length, 32);
    });

    test('등급별 분포: Common 12, Rare 10, Epic 6, Legendary 4', () {
      expect(allSkills.where((s) => s.rarity == SkillRarity.common).length, 12);
      expect(allSkills.where((s) => s.rarity == SkillRarity.rare).length, 10);
      expect(allSkills.where((s) => s.rarity == SkillRarity.epic).length, 6);
      expect(allSkills.where((s) => s.rarity == SkillRarity.legendary).length, 4);
    });

    test('스킬 ID 유일', () {
      final ids = allSkills.map((s) => s.id).toSet();
      expect(ids.length, allSkills.length);
    });

    test('모든 스킬에 nameKo 존재', () {
      for (final skill in allSkills) {
        expect(skill.nameKo.isNotEmpty, isTrue, reason: '${skill.id}의 nameKo 비어있음');
      }
    });

    test('모든 스킬에 shopCost > 0', () {
      for (final skill in allSkills) {
        expect(skill.shopCost, greaterThan(0), reason: '${skill.id}의 shopCost <= 0');
      }
    });
  });

  group('부적 데이터 무결성', () {
    test('전체 부적 7개', () {
      expect(allTalismans.length, 7);
    });

    test('부적 ID 유일', () {
      final ids = allTalismans.map((t) => t.id).toSet();
      expect(ids.length, allTalismans.length);
    });
  });

  group('상점 아이템 데이터 무결성', () {
    test('액티브 스킬 3개', () {
      expect(shopActiveSkills.length, 3);
    });

    test('라운드 소모품 3개', () {
      expect(shopPreRoundItems.length, 3);
    });

    test('영구 부적 2개', () {
      expect(shopPassiveTalismans.length, 2);
    });

    test('findItemById -- 모든 아이템 검색 가능', () {
      for (final item in [...shopActiveSkills, ...shopPreRoundItems, ...shopPassiveTalismans]) {
        final found = findItemById(item.id);
        expect(found, isNotNull, reason: '${item.id} 검색 실패');
        expect(found!.nameKo, item.nameKo);
      }
    });

    test('findItemById -- 없는 ID는 null', () {
      expect(findItemById('nonexistent'), isNull);
    });
  });
}
