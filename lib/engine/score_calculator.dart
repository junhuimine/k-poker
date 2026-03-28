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
library;

import '../models/card_def.dart';
import '../models/round_state.dart';
import '../models/run_state.dart';
import 'synergy_evaluator.dart';
import 'item_effect_resolver.dart';

/// 점수 상세 항목 (i18n 키 기반)
class ScoreEntry {
  /// i18n 키 (예: 'yaku_ogwang', 'penalty_gwangbak')
  final String key;

  /// 기본 점수 (배율 항목이면 0)
  final int points;

  /// 배율 (기본 점수 항목이면 1.0)
  final double mult;

  /// true면 배율 항목, false면 기본 점수 항목
  final bool isMultiplier;

  /// 부가 정보 (장수 등 — "{count}" 치환용)
  final Map<String, String> params;

  const ScoreEntry({
    required this.key,
    this.points = 0,
    this.mult = 1.0,
    this.isMultiplier = false,
    this.params = const {},
  });

  /// JSON 직렬화 (RoundState의 freezed 호환)
  Map<String, dynamic> toJson() => {
    'key': key,
    'points': points,
    'mult': mult,
    'isMultiplier': isMultiplier,
    'params': params,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    key: json['key'] as String,
    points: json['points'] as int? ?? 0,
    mult: (json['mult'] as num?)?.toDouble() ?? 1.0,
    isMultiplier: json['isMultiplier'] as bool? ?? false,
    params: (json['params'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v.toString())) ?? const {},
  );
}

/// 점수 계산 결과
class ScoreResult {
  final int baseChips;
  final double multiplier;
  final int finalScore;
  final List<String> appliedYaku;
  final List<ScoreEntry> breakdown;

  ScoreResult({
    required this.baseChips,
    required this.multiplier,
    required this.finalScore,
    required this.appliedYaku,
    this.breakdown = const [],
  });

  @override
  String toString() => 'Score: $finalScore (base $baseChips x ${multiplier.toStringAsFixed(1)})';
}

class ScoreCalculator {
  /// 현재 라운드 상태와 런 상태를 기반으로 점수를 계산
  static ScoreResult calculate(RoundState round, RunState run) {
    int basePoints = 0;
    double penaltyMult = 1.0;
    List<String> yakuList = [];
    List<ScoreEntry> breakdown = [];

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
        yakuList.add('yaku_cup_as_junk');
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
    // ps_double_junk: 쌍피 값 변경 (기본 2 -> specialEffects에서 변경 가능)
    // 사전에 ItemEffectResolver를 호출하여 specialEffects 확인
    final preItemEffects = ItemEffectResolver.resolveAll(
      run: run,
      round: round,
      playerCaptured: captured,
    );
    final doubleJunkValue = (preItemEffects.specialEffects['doubleJunkValue'] as int?) ?? 2;

    int junkCount = 0;
    for (var j in junks) {
      junkCount += j.def.doubleJunk ? doubleJunkValue : 1;
    }
    if (cupAsJunk) junkCount += doubleJunkValue; // 국화 술잔도 쌍피 값 적용

    // ═══════════════════════════════════
    // 2. 족보 판정 (공식 고스톱 점수)
    // ═══════════════════════════════════

    // --- 광 (Brights) ---
    final brightIds = brights.map((b) => b.def.id).toSet();
    final hasRain = brightIds.contains('m12_bright');

    if (brightIds.length == 5) {
      basePoints += 15;
      yakuList.add('yaku_ogwang');
      breakdown.add(const ScoreEntry(key: 'yaku_ogwang', points: 15));
    } else if (brightIds.length == 4 && !hasRain) {
      basePoints += 4;
      yakuList.add('yaku_sagwang');
      breakdown.add(const ScoreEntry(key: 'yaku_sagwang', points: 4));
    } else if (brightIds.length == 4 && hasRain) {
      // 비광 포함 4광 = 4점 (일부 룰에서)
      basePoints += 4;
      yakuList.add('yaku_bisagwang');
      breakdown.add(const ScoreEntry(key: 'yaku_bisagwang', points: 4));
    } else if (brightIds.length == 3 && hasRain) {
      basePoints += 2;
      yakuList.add('yaku_bisamgwang');
      breakdown.add(const ScoreEntry(key: 'yaku_bisamgwang', points: 2));
    } else if (brightIds.length >= 3 && !hasRain) {
      basePoints += 3;
      yakuList.add('yaku_samgwang');
      breakdown.add(const ScoreEntry(key: 'yaku_samgwang', points: 3));
    }

    // --- 고도리 (2월+4월+8월 새) ---
    final birdMonths = captured
        .where((c) => c.def.isBird)
        .map((c) => c.def.month)
        .toSet();
    if (birdMonths.containsAll({2, 4, 8})) {
      basePoints += 5;
      yakuList.add('yaku_godori');
      breakdown.add(const ScoreEntry(key: 'yaku_godori', points: 5));
    }

    // --- 홍단 (1,2,3월 빨간 띠) ---
    final redMonths = captured
        .where((c) => c.def.ribbonType == RibbonType.red)
        .map((c) => c.def.month)
        .toSet();
    if (redMonths.containsAll({1, 2, 3})) {
      basePoints += 3;
      yakuList.add('yaku_hongdan');
      breakdown.add(const ScoreEntry(key: 'yaku_hongdan', points: 3));
    }

    // --- 청단 (6,9,10월 파란 띠) ---
    final blueMonths = captured
        .where((c) => c.def.ribbonType == RibbonType.blue)
        .map((c) => c.def.month)
        .toSet();
    if (blueMonths.containsAll({6, 9, 10})) {
      basePoints += 3;
      yakuList.add('yaku_cheongdan');
      breakdown.add(const ScoreEntry(key: 'yaku_cheongdan', points: 3));
    }

    // --- 초단 (4,5,7월 초록 띠) ---
    final grassMonths = captured
        .where((c) => c.def.ribbonType == RibbonType.grass)
        .map((c) => c.def.month)
        .toSet();
    if (grassMonths.containsAll({4, 5, 7})) {
      basePoints += 3;
      yakuList.add('yaku_chodan');
      breakdown.add(const ScoreEntry(key: 'yaku_chodan', points: 3));
    }

    // --- 띠 5장 이상 ---
    if (ribbons.length >= 5) {
      final pts = 1 + (ribbons.length - 5);
      basePoints += pts;
      yakuList.add('yaku_ribbon_count');
      breakdown.add(ScoreEntry(
        key: 'yaku_ribbon_count',
        points: pts,
        params: {'count': '${ribbons.length}'},
      ));
    }

    // --- 동물 (열끗) 5장 이상 ---
    if (animals.length >= 5) {
      final pts = 1 + (animals.length - 5);
      basePoints += pts;
      yakuList.add('yaku_animal_count');
      breakdown.add(ScoreEntry(
        key: 'yaku_animal_count',
        points: pts,
        params: {'count': '${animals.length}'},
      ));
    }

    // --- 피 점수 (기본 10장, ps_junk_collector로 8장, syn_junk_empire로 추가 -1) ---
    final junkThresholdBase = (preItemEffects.specialEffects['junkThreshold'] as int?) ?? 10;
    final junkThresholdReduction = (preItemEffects.specialEffects['junkThresholdReduction'] as int?) ?? 0;
    final junkThreshold = junkThresholdBase - junkThresholdReduction;
    if (junkCount >= junkThreshold) {
      final pts = 1 + (junkCount - junkThreshold);
      basePoints += pts;
      yakuList.add('yaku_junk_count');
      breakdown.add(ScoreEntry(
        key: 'yaku_junk_count',
        points: pts,
        params: {'count': '$junkCount'},
      ));
    }

    // --- 쓸어먹기 ---
    if (round.sweepCount > 0) {
      basePoints += round.sweepCount;
      yakuList.add('yaku_sweep');
      breakdown.add(ScoreEntry(
        key: 'yaku_sweep',
        points: round.sweepCount,
        params: {'count': '${round.sweepCount}'},
      ));
    }

    // ═══════════════════════════════════
    // 3. 고(Go) 보너스
    // ═══════════════════════════════════
    // 전통 고스톱: n고 = +n점, 3고부터 추가로 x2^(n-2) 배율
    final goCount = round.goCount;
    if (goCount >= 1) {
      basePoints += goCount;
      if (goCount >= 3) {
        final goMult = 1 << (goCount - 2); // 3고=x2, 4고=x4, 5고=x8...
        penaltyMult *= goMult;
        yakuList.add('yaku_go_high');
        breakdown.add(ScoreEntry(
          key: 'yaku_go_points',
          points: goCount,
          params: {'count': '$goCount'},
        ));
        breakdown.add(ScoreEntry(
          key: 'yaku_go_mult',
          mult: goMult.toDouble(),
          isMultiplier: true,
          params: {'count': '$goCount', 'mult': '$goMult'},
        ));

        // t_gambler_soul 효과는 ItemEffectResolver에서 일괄 처리 (이중적용 방지)
      } else {
        yakuList.add('yaku_go_low');
        breakdown.add(ScoreEntry(
          key: 'yaku_go_points',
          points: goCount,
          params: {'count': '$goCount'},
        ));
      }
    }

    // ═══════════════════════════════════
    // 4. 박 배율 (상대에게 페널티)
    // ═══════════════════════════════════

    // 광박: 내가 3광 이상 족보가 있고, 상대가 광 0장
    if (brights.length >= 3 && oppBrights == 0) {
      penaltyMult *= 2;
      yakuList.add('penalty_gwangbak');
      breakdown.add(const ScoreEntry(
        key: 'penalty_gwangbak',
        mult: 2.0,
        isMultiplier: true,
      ));
    }

    // 피박: 내가 피 기준장수 이상, 상대가 피 7장 미만 (0장 포함)
    if (junkCount >= junkThreshold && oppJunkCount < 7) {
      penaltyMult *= 2;
      yakuList.add('penalty_pibak');
      breakdown.add(const ScoreEntry(
        key: 'penalty_pibak',
        mult: 2.0,
        isMultiplier: true,
      ));
    }

    // 띠박: 내가 띠 5장 이상이고, 상대 띠 0장
    if (ribbons.length >= 5 && oppRibbons == 0) {
      penaltyMult *= 2;
      yakuList.add('penalty_ttibak');
      breakdown.add(const ScoreEntry(
        key: 'penalty_ttibak',
        mult: 2.0,
        isMultiplier: true,
      ));
    }

    // 멍박: 내가 동물 7장 이상이고, 상대 동물 0장 (공식 규칙)
    if (animals.length >= 7 && oppAnimals == 0) {
      penaltyMult *= 2;
      yakuList.add('penalty_meongbak');
      breakdown.add(const ScoreEntry(
        key: 'penalty_meongbak',
        mult: 2.0,
        isMultiplier: true,
      ));
    }

    // ═══════════════════════════════════
    // 5. Roguelike 스킬 효과 (Balatro 요소)
    // ═══════════════════════════════════
    // 에디션 효과는 SynergyEvaluator에서 일괄 처리 (이중적용 방지)
    int bonusChips = 0;
    double skillMult = 1.0;

    // 시너지 체인 평가 (패시브 아이템 기반 — 에디션 효과)
    final synergyResult = SynergyEvaluator.evaluate(
      baseChips: bonusChips,
      baseMult: skillMult,
      capturedCards: captured,
      ownedPassives: run.ownedPassiveItems,
    );

    if (synergyResult.log.isNotEmpty) {
      yakuList.addAll(synergyResult.log);
    }

    // ═══════════════════════════════════
    // 5b. ItemEffectResolver 통합 (패시브 + 부적 + 소모품 + 시너지)
    // ═══════════════════════════════════
    final itemEffects = ItemEffectResolver.resolveAll(
      run: run,
      round: round,
      playerCaptured: captured,
    );

    // 패시브/부적/소모품/시너지 chips 합산
    final passiveChips = itemEffects.chips;
    // 패시브/부적/소모품/시너지 mult 합산
    final passiveMult = itemEffects.mult;
    // 패시브/부적/소모품/시너지 xMult 합산 (곱연산)
    final passiveXMult = itemEffects.xMult;

    // breakdown에 아이템 효과 추가
    if (passiveChips > 0) {
      breakdown.add(ScoreEntry(
        key: 'item_bonus_chips',
        points: passiveChips,
        params: {'chips': '$passiveChips'},
      ));
    }
    if (passiveMult > 0) {
      breakdown.add(ScoreEntry(
        key: 'item_bonus_mult',
        mult: passiveMult,
        isMultiplier: true,
        params: {'mult': passiveMult.toStringAsFixed(1)},
      ));
    }
    if (passiveXMult != 1.0) {
      breakdown.add(ScoreEntry(
        key: 'item_bonus_xmult',
        mult: passiveXMult,
        isMultiplier: true,
        params: {'xmult': passiveXMult.toStringAsFixed(2)},
      ));
    }

    // 아이템 효과 로그를 yakuList에 추가
    yakuList.addAll(itemEffects.log);

    // 광박 방패 (t_gwangbak_shield) 효과
    final hasGwangbakShield = itemEffects.specialEffects['nullifyGwangbak'] == true;
    if (hasGwangbakShield && yakuList.contains('penalty_gwangbak')) {
      // 광박 페널티 무효화: 광박 배율을 역으로 제거
      penaltyMult /= 2;
      yakuList.remove('penalty_gwangbak');
      breakdown.removeWhere((e) => e.key == 'penalty_gwangbak');
      yakuList.add('talisman_gwangbak_shield');
      breakdown.add(const ScoreEntry(
        key: 'talisman_gwangbak_shield',
        mult: 1.0,
        isMultiplier: true,
      ));
    }

    // ═══════════════════════════════════
    // 6. specialEffects 소비: 동물 점수 배율, 띠 2배, 폭탄 도화선, 요새, 꽃폭탄, 도발
    // ═══════════════════════════════════

    // t_mountain_charm: 동물 점수 x1.5
    final animalXMult = (itemEffects.specialEffects['animalXMult'] as double?);
    if (animalXMult != null && animals.length >= 5) {
      final animalPts = 1 + (animals.length - 5);
      final bonusAnimalPts = (animalPts * animalXMult).round() - animalPts;
      if (bonusAnimalPts > 0) {
        basePoints += bonusAnimalPts;
        yakuList.add('talisman_mountain_charm');
        breakdown.add(ScoreEntry(
          key: 'talisman_mountain_charm',
          points: bonusAnimalPts,
          params: {'mult': animalXMult.toStringAsFixed(1)},
        ));
      }
    }

    // c_ribbon_polish: 띠 점수 2배
    if (itemEffects.specialEffects['doubleRibbonScore'] == true) {
      // 띠 관련 기본 점수 항목 찾아서 2배 적용
      int ribbonBasePoints = 0;
      for (final entry in breakdown) {
        if (entry.key == 'yaku_ribbon_count' ||
            entry.key == 'yaku_hongdan' ||
            entry.key == 'yaku_cheongdan' ||
            entry.key == 'yaku_chodan') {
          ribbonBasePoints += entry.points;
        }
      }
      if (ribbonBasePoints > 0) {
        basePoints += ribbonBasePoints; // 원래 점수에 동일값 추가 = 2배
        yakuList.add('consumable_ribbon_polish');
        breakdown.add(ScoreEntry(
          key: 'consumable_ribbon_polish',
          points: ribbonBasePoints,
          params: {'original': '$ribbonBasePoints'},
        ));
      }
    }

    // c_bomb_fuse: 폭탄/총통 사용 시 x4.0
    final bombFuseXMult = (itemEffects.specialEffects['bombFuseXMult'] as double?);
    if (bombFuseXMult != null && round.bombUsed) {
      penaltyMult *= bombFuseXMult;
      yakuList.add('consumable_bomb_fuse');
      breakdown.add(ScoreEntry(
        key: 'consumable_bomb_fuse',
        mult: bombFuseXMult,
        isMultiplier: true,
        params: {'xmult': bombFuseXMult.toStringAsFixed(1)},
      ));
    }

    // syn_fortress: 박 패널티 -25%
    final bakReduction = (itemEffects.specialEffects['bakPenaltyReduction'] as double?);
    if (bakReduction != null && penaltyMult > 1.0) {
      // 박 페널티 부분만 25% 감소: newPenalty = 1 + (penalty - 1) * (1 - reduction)
      final penaltyPart = penaltyMult - 1.0;
      final reducedPart = penaltyPart * (1.0 - bakReduction);
      final oldPenalty = penaltyMult;
      penaltyMult = 1.0 + reducedPart;
      yakuList.add('synergy_fortress');
      breakdown.add(ScoreEntry(
        key: 'synergy_fortress',
        mult: penaltyMult / oldPenalty,
        isMultiplier: true,
        params: {'reduction': '${(bakReduction * 100).round()}%'},
      ));
    }

    // ps_flower_bomb: 같은 월 3장 핸드 보유 시 x3.0
    final tripleHandXMult = (itemEffects.specialEffects['tripleHandXMult'] as double?);
    if (tripleHandXMult != null && round.hadTripleMonth) {
      penaltyMult *= tripleHandXMult;
      yakuList.add('passive_flower_bomb');
      breakdown.add(ScoreEntry(
        key: 'passive_flower_bomb',
        mult: tripleHandXMult,
        isMultiplier: true,
        params: {'xmult': tripleHandXMult.toStringAsFixed(1)},
      ));
    }

    // ps_provoke: 도발 — 핸드 공개 x2.0
    if (itemEffects.specialEffects['provokeActive'] == true) {
      penaltyMult *= 2.0;
      yakuList.add('passive_provoke');
      breakdown.add(const ScoreEntry(
        key: 'passive_provoke',
        mult: 2.0,
        isMultiplier: true,
        params: {'xmult': '2.0'},
      ));
    }

    // 최종 계산: (기본 점수 + 에디션 보너스 + 아이템 보너스) x 박 배율 x 에디션 배율 x 아이템 배율 x 아이템 xMult
    final totalBase = basePoints + synergyResult.chips + passiveChips;
    double totalMult = penaltyMult * (synergyResult.mult + passiveMult).clamp(1.0, double.infinity) * passiveXMult;

    // 흔들기: 선언 시 점수 2배
    if (round.isShaking) {
      totalMult *= 2.0;
      yakuList.add('shake');
      breakdown.add(const ScoreEntry(
        key: 'shake_bonus',
        mult: 2.0,
        isMultiplier: true,
        params: {'xmult': '2.0'},
      ));
    }

    // synergyResult.mult가 1.0 미만이 될 수 있으므로 최솟값 보정
    if (totalMult < 1.0 && basePoints > 0) {
      totalMult = 1.0;
    }

    final finalScore = (totalBase * totalMult).round();

    return ScoreResult(
      baseChips: basePoints,
      multiplier: totalMult,
      finalScore: finalScore < 0 ? 0 : finalScore,
      appliedYaku: yakuList,
      breakdown: breakdown,
    );
  }
}
