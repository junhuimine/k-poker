/// 🎴 K-Poker — 점수 계산 엔진 (Balatro 스타일)
/// 
/// 설계 원칙: Score = Chips × Mult
/// 1. 족보(Yaku) 판정 -> Base Chips 부여
/// 2. 족보 보너스 -> +Mult 부여
/// 3. 시즈닝(Skills/Editions) -> +Mult 또는 ×Mult 부여

import '../models/card_def.dart';
import '../models/round_state.dart';
import '../models/run_state.dart';
import 'synergy_evaluator.dart';

/// 점수 계산 결과
class ScoreResult {
  final int baseChips;
  final double multiplier;
  final int finalScore;
  final List<String> appliedYaku;

  ScoreResult({
    required this.baseChips,
    required this.multiplier,
    required this.finalScore,
    required this.appliedYaku,
  });

  @override
  String toString() => 'Score: $finalScore ($baseChips × ${multiplier.toStringAsFixed(1)})';
}

class ScoreCalculator {
  /// 현재 라운드 상태와 런 상태를 기반으로 점수를 계산
  static ScoreResult calculate(RoundState round, RunState run) {
    int totalChips = 0;
    double totalMult = 1.0;
    List<String> yakuList = [];

    // 1. 획득한 카드 분류
    final captured = round.playerCaptured;
    final brights = captured.where((c) => c.def.grade == CardGrade.bright).toList();
    final ribbons = captured.where((c) => c.def.grade == CardGrade.ribbon).toList();
    final animals = captured.where((c) => c.def.grade == CardGrade.animal).toList();
    final junks = captured.where((c) => c.def.grade == CardGrade.junk).toList();

    // 2. 족보 판정 및 Chips/Mult 가산
    
    // --- 광 (Brights) ---
    if (brights.length == 5) {
      totalChips += 150;
      totalMult += 10.0;
      yakuList.add('오광');
    } else if (brights.length == 4) {
      totalChips += 40;
      totalMult += 4.0;
      yakuList.add('사광');
    } else if (brights.length == 3) {
      final hasRain = brights.any((c) => c.def.month == 12);
      if (hasRain) {
        totalChips += 20;
        totalMult += 2.0;
        yakuList.add('비삼광');
      } else {
        totalChips += 30;
        totalMult += 3.0;
        yakuList.add('삼광');
      }
    }

    // --- 고도리 (Godori) ---
    final birds = captured.where((c) => c.def.isBird).length;
    if (birds == 3) {
      totalChips += 50;
      totalMult += 5.0;
      yakuList.add('고도리');
    }

    // --- 띠 (Ribbons) ---
    final redRibbons = captured.where((c) => c.def.ribbonType == RibbonType.red).length;
    final blueRibbons = captured.where((c) => c.def.ribbonType == RibbonType.blue).length;
    final grassRibbons = captured.where((c) => c.def.ribbonType == RibbonType.grass).length;

    if (redRibbons == 3) {
      totalChips += 30;
      totalMult += 3.0;
      yakuList.add('홍단');
    }
    if (blueRibbons == 3) {
      totalChips += 30;
      totalMult += 3.0;
      yakuList.add('청단');
    }
    if (grassRibbons == 3) {
      totalChips += 30;
      totalMult += 3.0;
      yakuList.add('초단');
    }

    if (ribbons.length >= 5) {
      final extra = ribbons.length - 4;
      totalChips += extra * 10;
      totalMult += extra * 1.0;
      yakuList.add('띠 ${ribbons.length}장');
    }

    // --- 동물 (Animals) ---
    if (animals.length >= 5) {
      final extra = animals.length - 4;
      totalChips += extra * 10;
      totalMult += extra * 1.0;
      yakuList.add('동물 ${animals.length}장');
    }

    // --- 피 (Junks) ---
    int junkCount = 0;
    for (var j in junks) {
      junkCount += j.def.doubleJunk ? 2 : 1;
    }
    if (junkCount >= 10) {
      final extra = junkCount - 9;
      totalChips += extra * 10;
      totalMult += extra * 1.0;
      yakuList.add('피 $junkCount장');
    }

    // --- 쓸어먹기 보너스 (sweep) ---
    if (round.sweepCount > 0) {
      totalChips += round.sweepCount * 20;
      yakuList.add('쓸 ${round.sweepCount}회 (+${round.sweepCount * 20})');
    }

    // --- 연속타 보너스 ---
    if (round.comboCount >= 3) {
      totalChips += (round.comboCount ~/ 3) * 10;
      yakuList.add('연속 ${round.comboCount}타 (+${(round.comboCount ~/ 3) * 10})');
    }

    // 3. 개별 카드 에디션 및 강화 효과 적용 (Balatro)
    for (var card in captured) {
      if (card.edition == Edition.foil) totalChips += 50;
      if (card.edition == Edition.holographic) totalMult += 10.0;
      if (card.edition == Edition.polychrome) totalMult *= 1.5;
    }

    // 4. 시너지 체인 평가 (Balatro 스타일)
    final synergyResult = SynergyEvaluator.evaluate(
      baseChips: totalChips,
      baseMult: totalMult,
      capturedCards: captured,
      activeSkills: run.activeSkills,
    );
    
    totalChips = synergyResult.chips;
    totalMult = synergyResult.mult;
    yakuList.addAll(synergyResult.log);

    // 5. 고스톱 패널티 (박) 및 특수 배율 적용
    // 광박: 패자(상대)가 광 0장 보유 중일 때 광으로 점수를 냈다면 x2
    if (brights.isNotEmpty && round.opponentCaptured.where((c) => c.def.grade == CardGrade.bright).isEmpty) {
      totalMult *= 2.0;
      yakuList.add('광박 (x2.0)');
    }
    
    // 피박: 패자(상대)가 피 6장 미만일 때 피로 점수를 냈다면 x2
    int oppJunkCount = 0;
    for (var j in round.opponentCaptured.where((c) => c.def.grade == CardGrade.junk)) {
      oppJunkCount += j.def.doubleJunk ? 2 : 1;
    }
    if (junkCount >= 10 && oppJunkCount < 6 && oppJunkCount > 0) {
      totalMult *= 2.0;
      yakuList.add('피박 (x2.0)');
    }

    // 띠박: 상대가 띠 0장일 때
    if (ribbons.isNotEmpty && round.opponentCaptured.where((c) => c.def.grade == CardGrade.ribbon).isEmpty) {
      totalMult *= 2.0;
      yakuList.add('띠박 (x2.0)');
    }

    return ScoreResult(
      baseChips: totalChips,
      multiplier: totalMult,
      finalScore: (totalChips * totalMult).floor(),
      appliedYaku: yakuList,
    );
  }
}
