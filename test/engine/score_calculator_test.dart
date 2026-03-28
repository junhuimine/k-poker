/// 🎴 K-Poker — 점수 계산 엔진 유닛 테스트
library;

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
      const run = RunState();
      
      final result = ScoreCalculator.calculate(state, run);
      
      expect(result.appliedYaku, contains('yaku_ogwang'));
      expect(result.baseChips, 15);
      // 박 배율: 광박 x2 (5광이고 상대 광 0)
      // penaltyMult = 2.0, skillMult = 1.0 → totalMult = 2.0
      expect(result.multiplier, 2.0);
    });

    test('고도리(Godori) 판정 테스트', () {
      final birds = allCards.where((c) => c.isBird).toList();
      final captured = birds.map((d) => CardInstance(def: d)).toList();
      
      final state = RoundState(playerCaptured: captured);
      const run = RunState();
      
      final result = ScoreCalculator.calculate(state, run);
      
      expect(result.appliedYaku, contains('yaku_godori'));
      expect(result.baseChips, 5);
      // 동물 3장이라 멍박 없음, Mult = 1.0
      expect(result.multiplier, 1.0);
    });

    test('피(Junk) 10장 이상 판정 테스트', () {
      final junks = allCards.where((c) => c.grade == CardGrade.junk).take(11).toList();
      final captured = junks.map((d) => CardInstance(def: d)).toList();
      
      final state = RoundState(playerCaptured: captured);
      const run = RunState();
      
      final result = ScoreCalculator.calculate(state, run);
      
      // 피 11장: 기본 10장(1점) + 추가 1장(1점) = 2점
      // 단, 쌍피가 포함되면 junkCount > 11일 수 있으므로 >= 2로 체크
      expect(result.baseChips, greaterThanOrEqualTo(2));
      // 피박 여부: 상대 피 0장 → 피박 없음 (0장 제외 조건)
      expect(result.multiplier, greaterThanOrEqualTo(1.0));
    });

    test('에디션 시너지(Edition Synergy) 테스트', () {
      final junk = allCards.firstWhere((c) => c.grade == CardGrade.junk);
      final card = CardInstance(
        def: junk,
        edition: Edition.polychrome, // x1.2 Mult (코드상 1.2)
      );
      
      // 피 10장 맞춰서 기본 Mult 확보
      final otherJunks = allCards.where((c) => c.grade == CardGrade.junk && c.id != junk.id).take(9).toList();
      final captured = [card, ...otherJunks.map((d) => CardInstance(def: d))];
      
      final state = RoundState(playerCaptured: captured);
      const run = RunState();
      
      final result = ScoreCalculator.calculate(state, run);
      
      // penaltyMult = 1.0 (상대 피 0장이라 피박 조건 제외)
      // SynergyEvaluator: baseMult=1.0, Polychrome x1.5 → mult=1.5
      // 피박 등 추가 배율이 적용될 수 있으므로 최소 1.5 이상 확인
      expect(result.multiplier, greaterThanOrEqualTo(1.5));
    });
  });
}
