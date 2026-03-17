/// 🎴 K-Poker — 점수 계산 엔진 (공식 고스톱 룰)
///
/// 공식 고스톱 점수 체계:
/// - 광: 3광=3점, 비삼광=2점, 4광=4점, 오광=15점
/// - 고도리: 2,4,8월 새 3마리 = 5점
/// - 띠: 홍단/청단/초단 = 3점, 띠 5장=1점, 추가 1장당 +1점
/// - 동물: 5장=1점, 추가 1장당 +1점
/// - 피: 10장=1점, 추가 1장당 +1점
/// - 박: 광박/피박/띠박/멍박 = x2 배율 (누적 곱)
/// - 고: 1고=+1점, 2고=+2점, 3고=x2, 4고=x4...

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
  String toString() => 'Score: $finalScore (base $baseChips × ${multiplier.toStringAsFixed(1)})';
}

class ScoreCalculator {
  /// 현재 라운드 상태와 런 상태를 기반으로 점수를 계산
  static ScoreResult calculate(RoundState round, RunState run) {
    int basePoints = 0;
    double penaltyMult = 1.0;
    List<String> yakuList = [];

    // 1. 획득한 카드 분류
    final captured = round.playerCaptured;
    final brights = captured.where((c) => c.def.grade == CardGrade.bright).toList();
    final ribbons = captured.where((c) => c.def.grade == CardGrade.ribbon).toList();
    var animals = captured.where((c) => c.def.grade == CardGrade.animal).toList();
    final junks = captured.where((c) => c.def.grade == CardGrade.junk).toList();

    // 국화 술잔(m09_double) 양용 처리: 동물 vs 쌍피 자동 최적 선택
    final hasChrysanthemumCup = animals.any((c) => c.def.id == 'm09_double');
    bool cupAsJunk = false; // true = 쌍피로 계산
    if (hasChrysanthemumCup) {
      // 동물로 둘 때: animals.length 그대로 / 쌍피로 보낼 때: animals-1, junk+2
      final animalsWithCup = animals.length;
      final animalsWithoutCup = animals.length - 1;
      // 동물 5장 이상이면 점수, 아니면 0
      final animalPtsWithCup = animalsWithCup >= 5 ? 1 + (animalsWithCup - 5) : 0;
      final animalPtsWithoutCup = animalsWithoutCup >= 5 ? 1 + (animalsWithoutCup - 5) : 0;
      // 피 계산: 현재 피 + 쌍피 2장
      int currentJunkCount = 0;
      for (var j in junks) { currentJunkCount += j.def.doubleJunk ? 2 : 1; }
      final junkPtsNoCup = currentJunkCount >= 10 ? 1 + (currentJunkCount - 10) : 0;
      final junkPtsWithCup = (currentJunkCount + 2) >= 10 ? 1 + ((currentJunkCount + 2) - 10) : 0;
      // 쌍피로 보내는 게 더 유리한지 비교
      if ((animalPtsWithoutCup + junkPtsWithCup) > (animalPtsWithCup + junkPtsNoCup)) {
        cupAsJunk = true;
        animals = animals.where((c) => c.def.id != 'm09_double').toList();
        yakuList.add('🍶 국화술잔 → 쌍피');
      }
    }

    // 상대 카드 분류
    final oppBrights = round.opponentCaptured.where((c) => c.def.grade == CardGrade.bright).length;
    final oppRibbons = round.opponentCaptured.where((c) => c.def.grade == CardGrade.ribbon).length;
    final oppAnimals = round.opponentCaptured.where((c) => c.def.grade == CardGrade.animal).length;
    int oppJunkCount = 0;
    for (var j in round.opponentCaptured.where((c) => c.def.grade == CardGrade.junk)) {
      oppJunkCount += j.def.doubleJunk ? 2 : 1;
    }

    // 피 카운트 (쌍피 = 2장) + 국화 술잔이 쌍피로 전환됐으면 +2
    int junkCount = 0;
    for (var j in junks) {
      junkCount += j.def.doubleJunk ? 2 : 1;
    }
    if (cupAsJunk) junkCount += 2;

    // ═══════════════════════════════════
    // 2. 족보 판정 (공식 고스톱 점수)
    // ═══════════════════════════════════

    // --- 광 (Brights) ---
    final brightIds = brights.map((b) => b.def.id).toSet();
    final hasRain = brightIds.contains('m12_bright');

    if (brightIds.length == 5) {
      basePoints += 15;
      yakuList.add('⭐ 오광 (+15)');
    } else if (brightIds.length == 4 && !hasRain) {
      basePoints += 4;
      yakuList.add('🌟 사광 (+4)');
    } else if (brightIds.length == 4 && hasRain) {
      // 비광 포함 4광 = 4점 (일부 룰에서)
      basePoints += 4;
      yakuList.add('🌧️ 비사광 (+4)');
    } else if (brightIds.length == 3 && hasRain) {
      basePoints += 2;
      yakuList.add('🌧️ 비삼광 (+2)');
    } else if (brightIds.length >= 3 && !hasRain) {
      basePoints += 3;
      yakuList.add('🌟 삼광 (+3)');
    }

    // --- 고도리 (2월+4월+8월 새) ---
    final birdMonths = captured
        .where((c) => c.def.isBird)
        .map((c) => c.def.month)
        .toSet();
    if (birdMonths.containsAll({2, 4, 8})) {
      basePoints += 5;
      yakuList.add('🐦 고도리 (+5)');
    }

    // --- 홍단 (1,2,3월 빨간 띠) ---
    final redMonths = captured
        .where((c) => c.def.ribbonType == RibbonType.red)
        .map((c) => c.def.month)
        .toSet();
    if (redMonths.containsAll({1, 2, 3})) {
      basePoints += 3;
      yakuList.add('🎀 홍단 (+3)');
    }

    // --- 청단 (6,9,10월 파란 띠) ---
    final blueMonths = captured
        .where((c) => c.def.ribbonType == RibbonType.blue)
        .map((c) => c.def.month)
        .toSet();
    if (blueMonths.containsAll({6, 9, 10})) {
      basePoints += 3;
      yakuList.add('💎 청단 (+3)');
    }

    // --- 초단 (4,5,7월 초록 띠) ---
    final grassMonths = captured
        .where((c) => c.def.ribbonType == RibbonType.grass)
        .map((c) => c.def.month)
        .toSet();
    if (grassMonths.containsAll({4, 5, 7})) {
      basePoints += 3;
      yakuList.add('🌿 초단 (+3)');
    }

    // --- 띠 5장 이상 ---
    if (ribbons.length >= 5) {
      final pts = 1 + (ribbons.length - 5);
      basePoints += pts;
      yakuList.add('🎗️ 띠 ${ribbons.length}장 (+$pts)');
    }

    // --- 동물 (열끗) 5장 이상 ---
    if (animals.length >= 5) {
      final pts = 1 + (animals.length - 5);
      basePoints += pts;
      yakuList.add('🐾 동물 ${animals.length}장 (+$pts)');
    }

    // --- 피 10장 이상 ---
    if (junkCount >= 10) {
      final pts = 1 + (junkCount - 10);
      basePoints += pts;
      yakuList.add('🍂 피 $junkCount장 (+$pts)');
    }

    // --- 쓸어먹기 ---
    if (round.sweepCount > 0) {
      basePoints += round.sweepCount;
      yakuList.add('🧹 쓸 ${round.sweepCount}회 (+${round.sweepCount})');
    }

    // ═══════════════════════════════════
    // 3. 고(Go) 보너스
    // ═══════════════════════════════════
    final goCount = round.goCount;
    if (goCount == 1) {
      basePoints += 1;
      yakuList.add('🔥 1고 (+1)');
    } else if (goCount == 2) {
      basePoints += 2;
      yakuList.add('🔥 2고 (+2)');
    } else if (goCount >= 3) {
      // 3고부터 x2^(goCount-2)
      final goMult = 1 << (goCount - 2); // 3고=x2, 4고=x4, 5고=x8...
      penaltyMult *= goMult;
      yakuList.add('🔥 ${goCount}고 (x$goMult)');
    }

    // ═══════════════════════════════════
    // 4. 박 배율 (상대에게 페널티)
    // ═══════════════════════════════════

    // 광박: 내가 3광 이상 족보가 있고, 상대가 광 0장
    if (brights.length >= 3 && oppBrights == 0) {
      penaltyMult *= 2;
      yakuList.add('💥 광박 (x2)');
    }

    // 피박: 내가 피 10장 이상, 상대가 피 7장 미만 (0장 제외)
    if (junkCount >= 10 && oppJunkCount > 0 && oppJunkCount < 7) {
      penaltyMult *= 2;
      yakuList.add('🥊 피박 (x2)');
    }

    // 띠박: 내가 띠 5장 이상이고, 상대 띠 0장
    if (ribbons.length >= 5 && oppRibbons == 0) {
      penaltyMult *= 2;
      yakuList.add('🎗️ 띠박 (x2)');
    }

    // 멍박: 내가 동물 5장 이상이고, 상대 동물 0장
    if (animals.length >= 5 && oppAnimals == 0) {
      penaltyMult *= 2;
      yakuList.add('🐾 멍박 (x2)');
    }

    // ═══════════════════════════════════
    // 5. Roguelike 스킬 효과 (Balatro 요소)
    // ═══════════════════════════════════
    int bonusChips = 0;
    double skillMult = 1.0;

    // 개별 카드 에디션 효과
    for (var card in captured) {
      if (card.edition == Edition.foil) bonusChips += 5;
      if (card.edition == Edition.holographic) bonusChips += 3;
      if (card.edition == Edition.polychrome) skillMult *= 1.2;
    }

    // 시너지 체인 평가
    final synergyResult = SynergyEvaluator.evaluate(
      baseChips: bonusChips,
      baseMult: skillMult,
      capturedCards: captured,
      activeSkills: run.activeSkills,
    );

    if (synergyResult.log.isNotEmpty) {
      yakuList.addAll(synergyResult.log);
    }

    // 최종 계산: (기본 점수 + 스킬 보너스) × 박 배율 × 스킬 배율
    final totalBase = basePoints + synergyResult.chips;
    final totalMult = penaltyMult * synergyResult.mult;
    final finalScore = (totalBase * totalMult).round();

    return ScoreResult(
      baseChips: basePoints,
      multiplier: totalMult,
      finalScore: finalScore < 0 ? 0 : finalScore,
      appliedYaku: yakuList,
    );
  }
}
