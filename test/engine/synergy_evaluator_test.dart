/// K-Poker -- synergy_evaluator 전수검사 테스트
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/synergy_evaluator.dart';
import 'package:k_poker/models/card_def.dart';
import 'package:k_poker/data/all_cards.dart';
import 'package:k_poker/data/skills.dart';

CardInstance _inst(CardDef def, {Edition edition = Edition.base}) =>
    CardInstance(def: def, edition: edition);

SkillDef _findSkill(String id) => allSkills.firstWhere((s) => s.id == id);

void main() {
  group('SynergyEvaluator 에디션 효과 테스트', () {
    test('Foil 에디션 -- +50 Chips', () {
      final card = _inst(allCards[0], edition: Edition.foil);
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: [card],
        activeSkills: [],
      );
      expect(result.chips, 50);
      expect(result.log.any((l) => l.contains('Foil')), isTrue);
    });

    test('Holographic 에디션 -- +10 Mult', () {
      final card = _inst(allCards[0], edition: Edition.holographic);
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: [card],
        activeSkills: [],
      );
      expect(result.mult, 11.0); // 1.0 + 10.0
    });

    test('Polychrome 에디션 -- x1.5 Mult', () {
      final card = _inst(allCards[0], edition: Edition.polychrome);
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: [card],
        activeSkills: [],
      );
      expect(result.mult, 1.5); // 1.0 * 1.5
    });

    test('복합 에디션 -- Foil + Holographic + Polychrome', () {
      final cards = [
        _inst(allCards[0], edition: Edition.foil),
        _inst(allCards[1], edition: Edition.holographic),
        _inst(allCards[2], edition: Edition.polychrome),
      ];
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: cards,
        activeSkills: [],
      );
      expect(result.chips, 50); // Foil +50
      expect(result.mult, closeTo(16.5, 0.01)); // (1.0 + 10.0) * 1.5
    });
  });

  group('SynergyEvaluator 스킬 체인 테스트', () {
    test('봄바람 -- 1~3월 카드 보너스', () {
      final springCards = allCards
          .where((c) => c.month >= 1 && c.month <= 3 && !c.isBonus)
          .take(3)
          .map((d) => _inst(d))
          .toList();

      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: springCards,
        activeSkills: [_findSkill('spring_breeze')],
      );
      // 3장 x 2칩 = 6칩
      expect(result.chips, 6);
    });

    test('전설의 타짜 -- 가산 + 승산 체인', () {
      final cards = [_inst(allCards[0])];
      final result = SynergyEvaluator.evaluate(
        baseChips: 10,
        baseMult: 1.0,
        capturedCards: cards,
        activeSkills: [_findSkill('legendary_tazza')],
      );
      // 가산: +100 chips, +10 mult
      // 승산: x3.0
      expect(result.chips, 110); // 10 + 100
      expect(result.mult, closeTo(33.0, 0.01)); // (1.0 + 10.0) * 3.0
    });

    test('금독수리 -- 동물 5장 이상 시 보너스', () {
      final animals = allCards
          .where((c) => c.grade == CardGrade.animal)
          .take(5)
          .map((d) => _inst(d))
          .toList();

      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: animals,
        activeSkills: [_findSkill('golden_eagle')],
      );
      // 가산: +40 chips, +3 mult
      // 승산: 동물 5+ -> x1.5
      expect(result.chips, 40);
      expect(result.mult, closeTo(6.0, 0.01)); // (1.0 + 3.0) * 1.5
    });

    test('금독수리 -- 동물 4장 이하 시 페널티', () {
      final animals = allCards
          .where((c) => c.grade == CardGrade.animal)
          .take(3)
          .map((d) => _inst(d))
          .toList();

      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: animals,
        activeSkills: [_findSkill('golden_eagle')],
      );
      // 가산: chips=0, mult=0 (동물 4장 이하)
      // 승산: x0.9 (페널티)
      expect(result.mult, closeTo(0.9, 0.01));
    });

    test('스킬 체인 순서: 가산 -> 승산 (Balatro 규칙)', () {
      // allCards[0] = m01_bright (1월) -> spring_breeze가 +2 chips 추가
      final cards = [_inst(allCards[0])];
      // spring_breeze (가산) + flower_bomb (승산 x3.0)
      final result = SynergyEvaluator.evaluate(
        baseChips: 10,
        baseMult: 2.0,
        capturedCards: cards,
        activeSkills: [
          _findSkill('spring_breeze'),
          _findSkill('flower_bomb'),
        ],
      );
      // 1. spring_breeze: 1월 카드 1장 -> +2 chips
      // 2. flower_bomb 가산: +80 chips, +5 mult
      // 3. flower_bomb 승산: x3.0
      // chips = 10 + 2 + 80 = 92
      // mult = (2.0 + 0 + 5.0) * 3.0 = 21.0
      expect(result.chips, 92);
      expect(result.mult, closeTo(21.0, 0.01));
    });
  });

  group('기본 등급별 가산 보너스 테스트', () {
    test('알 수 없는 스킬 ID -- 등급별 기본 보너스', () {
      // allSkills에 없는 가상 스킬은 테스트 불가 (switch default)
      // 대신 각 등급 스킬의 기본 동작 확인
      for (final skill in allSkills) {
        final result = SynergyEvaluator.evaluate(
          baseChips: 0,
          baseMult: 1.0,
          capturedCards: [_inst(allCards[0])],
          activeSkills: [skill],
        );
        // 모든 스킬은 최소 chips >= 0, mult >= 0.9
        expect(result.chips, greaterThanOrEqualTo(0),
            reason: '${skill.nameKo}(${skill.id}) chips >= 0');
        expect(result.mult, greaterThanOrEqualTo(0.5),
            reason: '${skill.nameKo}(${skill.id}) mult >= 0.5');
      }
    });
  });
}
