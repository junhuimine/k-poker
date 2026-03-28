/// K-Poker -- synergy_evaluator 전수검사 테스트
///
/// SynergyEvaluator는 카드 에디션 효과(Foil/Holo/Poly)만 처리.
/// 개별 패시브/부적 효과는 ItemEffectResolver에서 처리.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/synergy_evaluator.dart';
import 'package:k_poker/models/card_def.dart';
import 'package:k_poker/data/all_cards.dart';
import 'package:k_poker/data/item_catalog.dart';

CardInstance _inst(CardDef def, {Edition edition = Edition.base}) =>
    CardInstance(def: def, edition: edition);

void main() {
  group('SynergyEvaluator 에디션 효과 테스트', () {
    test('Foil 에디션 -- +50 Chips', () {
      final card = _inst(allCards[0], edition: Edition.foil);
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: [card],
        ownedPassives: <ItemDef>[],
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
        ownedPassives: <ItemDef>[],
      );
      expect(result.mult, 11.0); // 1.0 + 10.0
    });

    test('Polychrome 에디션 -- x1.5 Mult', () {
      final card = _inst(allCards[0], edition: Edition.polychrome);
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: [card],
        ownedPassives: <ItemDef>[],
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
        ownedPassives: <ItemDef>[],
      );
      expect(result.chips, 50); // Foil +50
      expect(result.mult, closeTo(16.5, 0.01)); // (1.0 + 10.0) * 1.5
    });
  });

  group('SynergyEvaluator 기본 동작 테스트', () {
    test('에디션 없는 카드 -- 기본값 유지', () {
      final cards = [_inst(allCards[0])];
      final result = SynergyEvaluator.evaluate(
        baseChips: 10,
        baseMult: 2.0,
        capturedCards: cards,
        ownedPassives: <ItemDef>[],
      );
      expect(result.chips, 10);
      expect(result.mult, 2.0);
      expect(result.log, isEmpty);
    });

    test('빈 capturedCards -- 기본값 유지', () {
      final result = SynergyEvaluator.evaluate(
        baseChips: 5,
        baseMult: 3.0,
        capturedCards: <CardInstance>[],
        ownedPassives: <ItemDef>[],
      );
      expect(result.chips, 5);
      expect(result.mult, 3.0);
      expect(result.log, isEmpty);
    });

    test('가산 -> 승산 순서: Holo(+10) 후 Poly(x1.5)', () {
      final cards = [
        _inst(allCards[0], edition: Edition.holographic),
        _inst(allCards[1], edition: Edition.polychrome),
      ];
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 2.0,
        capturedCards: cards,
        ownedPassives: <ItemDef>[],
      );
      // Holo: 2.0 + 10.0 = 12.0 -> Poly: 12.0 * 1.5 = 18.0
      expect(result.mult, closeTo(18.0, 0.01));
    });

    test('Polychrome 2장 -- 순차 곱: x1.5 x1.5 = x2.25', () {
      final cards = [
        _inst(allCards[0], edition: Edition.polychrome),
        _inst(allCards[1], edition: Edition.polychrome),
      ];
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: cards,
        ownedPassives: <ItemDef>[],
      );
      expect(result.mult, closeTo(2.25, 0.01)); // 1.0 * 1.5 * 1.5
    });

    test('Foil 3장 -- 합산: +150 Chips', () {
      final cards = [
        _inst(allCards[0], edition: Edition.foil),
        _inst(allCards[1], edition: Edition.foil),
        _inst(allCards[2], edition: Edition.foil),
      ];
      final result = SynergyEvaluator.evaluate(
        baseChips: 0,
        baseMult: 1.0,
        capturedCards: cards,
        ownedPassives: <ItemDef>[],
      );
      expect(result.chips, 150); // 50 * 3
    });
  });
}
