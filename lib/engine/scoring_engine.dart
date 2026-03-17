// 🎴 K-Poker — 족보 점수 계산 엔진 (DEPRECATED)
//
// ⚠️ 이 파일은 더 이상 사용되지 않습니다.
// 실제 점수 계산은 score_calculator.dart의 ScoreCalculator를 사용하세요.
// 전통 고스톱 족보 구조 참고용으로만 보존합니다.

import '../models/card_def.dart';

/// 족보 결과
class YokboResult {
  final String name;
  final String nameKo;
  final String emoji;
  final int points;

  const YokboResult(this.name, this.nameKo, this.emoji, this.points);

  @override
  String toString() => '$emoji $nameKo ($points점)';
}

/// 콤보 결과
class ComboResult {
  final String name;
  final String nameKo;
  final String emoji;
  final int bonusPoints;
  final double bonusMulti;

  const ComboResult(this.name, this.nameKo, this.emoji, {this.bonusPoints = 0, this.bonusMulti = 1.0});
}

/// 최종 점수 정산 결과
class ScoringResult {
  final List<YokboResult> yokbos;       // 달성 족보 목록
  final List<ComboResult> combos;       // 콤보 보너스 목록
  final int basePoints;                 // 기본 점수 합
  final double goMultiplier;            // Go 배율
  final double penaltyMultiplier;       // 박/쓸/광박 배율
  final double skillMultiplier;         // 기술 배율
  final int totalPoints;                // 최종 점수
  
  const ScoringResult({
    required this.yokbos,
    required this.combos,
    required this.basePoints,
    required this.goMultiplier,
    required this.penaltyMultiplier,
    required this.skillMultiplier,
    required this.totalPoints,
  });
}

class ScoringEngine {
  
  /// 전체 점수 계산
  static ScoringResult calculate({
    required List<CardInstance> playerCaptured,
    required List<CardInstance> opponentCaptured,
    required int goCount,
    required int sweepCount,        // 쓸어먹기 횟수
    required int consecutiveMatches, // 연속 매칭 횟수
    required double skillMultiplier, // 기술에 의한 배율
  }) {
    final yokbos = calculateYokbos(playerCaptured);
    final combos = calculateCombos(
      sweepCount: sweepCount,
      consecutiveMatches: consecutiveMatches,
      playerCaptured: playerCaptured,
      opponentCaptured: opponentCaptured,
    );
    
    // 기본 점수 = 족보 합 + 콤보 보너스 점수
    int basePoints = 0;
    for (final y in yokbos) basePoints += y.points;
    for (final c in combos) basePoints += c.bonusPoints;
    
    // Go 배율
    double goMulti = 1.0;
    if (goCount == 1) goMulti = 1.0; // 1고: +1점 (이미 점수에 반영)
    if (goCount == 2) goMulti = 1.0; // 2고: +2점
    if (goCount >= 3) goMulti = 2.0; // 3고: ×2

    // Go 추가 점수 (1고=+1, 2고=+2)
    if (goCount >= 1 && goCount < 3) basePoints += goCount;
    
    // 박/쓸/광박 배율
    double penaltyMulti = _calculatePenaltyMultiplier(
      playerCaptured, opponentCaptured, sweepCount,
    );
    
    // 콤보 배율
    double comboMulti = 1.0;
    for (final c in combos) comboMulti *= c.bonusMulti;
    
    final totalMulti = goMulti * penaltyMulti * comboMulti * skillMultiplier;
    final totalPoints = (basePoints * totalMulti).round();
    
    return ScoringResult(
      yokbos: yokbos,
      combos: combos,
      basePoints: basePoints,
      goMultiplier: goMulti,
      penaltyMultiplier: penaltyMulti * comboMulti,
      skillMultiplier: skillMultiplier,
      totalPoints: totalPoints < 0 ? 0 : totalPoints,
    );
  }

  /// 족보 계산 (전통 고스톱)
  static List<YokboResult> calculateYokbos(List<CardInstance> captured) {
    final results = <YokboResult>[];
    
    final brights = captured.where((c) => c.def.grade == CardGrade.bright).toList();
    final animals = captured.where((c) => c.def.grade == CardGrade.animal).toList();
    final ribbons = captured.where((c) => c.def.grade == CardGrade.ribbon).toList();
    final junks = captured.where((c) => c.def.grade == CardGrade.junk).toList();
    
    // 피 계산 (쌍피는 2장으로)
    int junkCount = 0;
    for (final j in junks) {
      junkCount += j.def.doubleJunk ? 2 : 1;
    }
    // 동물 중 쌍피도 체크 (국화 술잔)
    for (final a in animals) {
      if (a.def.doubleJunk) junkCount += 1; // 술잔은 동물이자 피 1장 추가
    }
    
    // ─── 광 족보 ───
    final brightIds = brights.map((b) => b.def.id).toSet();
    final rainBright = brightIds.contains('m12_bright'); // 비광
    
    if (brightIds.length == 5) {
      results.add(const YokboResult('fiveBright', '오광', '🌟', 15));
    } else if (brightIds.length == 4 && !rainBright) {
      results.add(const YokboResult('fourBright', '사광', '🌟', 4));
    } else if (brightIds.length == 3 && rainBright) {
      results.add(const YokboResult('rainThreeBright', '비삼광', '🌧️', 2));
    } else if (brightIds.length >= 3 && !rainBright) {
      results.add(const YokboResult('threeBright', '삼광', '🌟', 3));
    }
    
    // ─── 고도리 (2월 꾀꼬리 + 4월 두견새 + 8월 기러기) ───
    final birdIds = animals.where((a) => a.def.isBird).map((a) => a.def.month).toSet();
    if (birdIds.containsAll({2, 4, 8})) {
      results.add(const YokboResult('godori', '고도리', '🐦', 5));
    }
    
    // ─── 홍단 (1~3월 빨간 띠) ───
    final redRibbonMonths = ribbons
        .where((r) => r.def.ribbonType == RibbonType.red)
        .map((r) => r.def.month)
        .toSet();
    if (redRibbonMonths.containsAll({1, 2, 3})) {
      results.add(const YokboResult('redRibbon', '홍단', '🎀', 3));
    }
    
    // ─── 청단 (6, 9, 10월 파란 띠) ───
    final blueRibbonMonths = ribbons
        .where((r) => r.def.ribbonType == RibbonType.blue)
        .map((r) => r.def.month)
        .toSet();
    if (blueRibbonMonths.containsAll({6, 9, 10})) {
      results.add(const YokboResult('blueRibbon', '청단', '💎', 3));
    }
    
    // ─── 초단 (4, 5, 7월 초록 띠) ───
    final grassRibbonMonths = ribbons
        .where((r) => r.def.ribbonType == RibbonType.grass)
        .map((r) => r.def.month)
        .toSet();
    if (grassRibbonMonths.containsAll({4, 5, 7})) {
      results.add(const YokboResult('grassRibbon', '초단', '🌿', 3));
    }
    
    // ─── 띠 5장 이상 ───
    if (ribbons.length >= 5) {
      final extra = ribbons.length - 5;
      results.add(YokboResult('ribbonFive', '띠 ${ribbons.length}장', '🎀', 1 + extra));
    }
    
    // ─── 동물 5장 이상 ───
    if (animals.length >= 5) {
      final extra = animals.length - 5;
      results.add(YokboResult('animalFive', '열끗 ${animals.length}장', '🐾', 1 + extra));
    }
    
    // ─── 피 10장 이상 (쌍피 포함) ───
    if (junkCount >= 10) {
      final extra = junkCount - 10;
      results.add(YokboResult('junkTen', '피 $junkCount장', '🍂', 1 + extra));
    }
    
    return results;
  }
  
  /// 콤보 보너스 계산
  static List<ComboResult> calculateCombos({
    required int sweepCount,
    required int consecutiveMatches,
    required List<CardInstance> playerCaptured,
    required List<CardInstance> opponentCaptured,
  }) {
    final combos = <ComboResult>[];
    
    // 🧹 쓸어먹기: 횟수당 +2점
    if (sweepCount > 0) {
      combos.add(ComboResult('sweep', '쓸 $sweepCount회', '🧹', bonusPoints: sweepCount * 2));
    }
    
    // ⚡ 연속타: 3회 이상 연속 매칭 시 +1점
    if (consecutiveMatches >= 3) {
      combos.add(ComboResult('combo', '연속 $consecutiveMatches타', '⚡', bonusPoints: consecutiveMatches ~/ 3));
    }
    
    // 🏆 압도 (박): 상대 광0/피0/띠0 시 배율
    final opBrights = opponentCaptured.where((c) => c.def.grade == CardGrade.bright).length;
    final opRibbons = opponentCaptured.where((c) => c.def.grade == CardGrade.ribbon).length;
    int opJunkCount = 0;
    for (final j in opponentCaptured.where((c) => c.def.grade == CardGrade.junk)) {
      opJunkCount += j.def.doubleJunk ? 2 : 1;
    }
    
    // 피 계산 (플레이어)
    int playerJunkCount = 0;
    for (final j in playerCaptured.where((c) => c.def.grade == CardGrade.junk)) {
      playerJunkCount += j.def.doubleJunk ? 2 : 1;
    }
    
    if (opBrights == 0 && playerCaptured.where((c) => c.def.grade == CardGrade.bright).isNotEmpty) {
      combos.add(const ComboResult('gwangBak', '광박', '💥', bonusMulti: 2.0));
    }
    if (playerJunkCount >= 10 && opJunkCount < 7) { // 피박: 내 피 10장+, 상대 피 7장 미만
      combos.add(const ComboResult('piBak', '피박', '🥊', bonusMulti: 2.0));
    }
    if (opRibbons == 0 && playerCaptured.where((c) => c.def.grade == CardGrade.ribbon).isNotEmpty) {
      combos.add(const ComboResult('ddiBak', '띠박', '🎗️', bonusMulti: 2.0));
    }
    
    return combos;
  }
  
  /// 박 배율 계산
  static double _calculatePenaltyMultiplier(
    List<CardInstance> player,
    List<CardInstance> opponent,
    int sweepCount,
  ) {
    double multi = 1.0;
    // 쓸 배율은 콤보에서 점수 추가로 처리, 여기서는 1.0
    return multi;
  }
}
