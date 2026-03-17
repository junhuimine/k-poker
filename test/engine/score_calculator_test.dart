/// 🎴 K-Poker — 점수 계산 엔진 유닛 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/score_calculator.dart';
import 'package:k_poker/models/card_def.dart';
import 'package:k_poker/models/round_state.dart';
import 'package:k_poker/models/run_state.dart';
import 'package:k_poker/data/all_cards.dart';

void main() {
  group('ScoreCalculator Tests', () {
    test('오광(Oh-Gwang) 판정 테스트', () {
      final brights = allCards.where((c) => c.grade == CardGrade.bright).toList();
      final captured = brights.map((d) => CardInstance(def: d)).toList();
      
      final state = RoundState(playerCaptured: captured);
      final run = const RunState();
      
      final result = ScoreCalculator.calculate(state, run);
      
      expect(result.appliedYaku, contains('오광'));
      expect(result.baseChips, 150);
      expect(result.multiplier, 11.0); // 기본 1 + 오광 10
    });

    test('고도리(Godori) 판정 테스트', () {
      final birds = allCards.where((c) => c.isBird).toList();
      final captured = birds.map((d) => CardInstance(def: d)).toList();
      
      final state = RoundState(playerCaptured: captured);
      final run = const RunState();
      
      final result = ScoreCalculator.calculate(state, run);
      
      expect(result.appliedYaku, contains('고도리'));
      expect(result.baseChips, 50);
      expect(result.multiplier, 6.0);
    });

    test('피(Junk) 10장 이상 판정 테스트', () {
      final junks = allCards.where((c) => c.grade == CardGrade.junk).take(11).toList();
      final captured = junks.map((d) => CardInstance(def: d)).toList();
      
      final state = RoundState(playerCaptured: captured);
      final run = const RunState();
      
      final result = ScoreCalculator.calculate(state, run);
      
      expect(result.appliedYaku, contains('피 11장'));
      expect(result.baseChips, 20); // 10장(10) + 추가 1장(10)
      expect(result.multiplier, 3.0); // 1 + 10장(1) + 추가 1장(1)
    });

    test('버전 시너지(Edition Synergy) 테스트', () {
      final junk = allCards.firstWhere((c) => c.grade == CardGrade.junk);
      final card = CardInstance(
        def: junk,
        edition: Edition.polychrome, // x1.5 Mult
      );
      
      // 피 10장 맞춰서 기본 Mult 확보
      final otherJunks = allCards.where((c) => c.grade == CardGrade.junk && c.id != junk.id).take(9).toList();
      final captured = [card, ...otherJunks.map((d) => CardInstance(def: d))];
      
      final state = RoundState(playerCaptured: captured);
      final run = const RunState();
      
      final result = ScoreCalculator.calculate(state, run);
      
      // 기본 피 10장 Mult = 2.0 (기본 1 + 1)
      // Polychrome 적용 시 2.0 * 1.5 = 3.0
      expect(result.multiplier, 3.0);
    });
  });
}
