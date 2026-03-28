/// K-Poker -- 통합 아이템 효과 해석기
///
/// 패시브, 부적, 소모품, 시너지의 효과를 한 곳에서 해석.
/// ScoreCalculator에서 호출하여 최종 점수에 반영.
library;

import '../models/card_def.dart';
import '../models/round_state.dart';
import '../models/run_state.dart';
import '../data/item_catalog.dart';
import '../data/synergy_defs.dart';

/// 아이템 효과 결과 (각 카테고리별 독립 합산)
class ItemEffectResult {
  final int chips;
  final double mult;
  final double xMult;
  final int bonusGold;
  final Map<String, dynamic> specialEffects;
  final List<String> log;

  const ItemEffectResult({
    this.chips = 0,
    this.mult = 0.0,
    this.xMult = 1.0,
    this.bonusGold = 0,
    this.specialEffects = const {},
    this.log = const [],
  });

  /// 두 결과를 합산
  ItemEffectResult merge(ItemEffectResult other) {
    final mergedSpecial = Map<String, dynamic>.from(specialEffects);
    for (final entry in other.specialEffects.entries) {
      mergedSpecial[entry.key] = entry.value;
    }
    return ItemEffectResult(
      chips: chips + other.chips,
      mult: mult + other.mult,
      xMult: xMult * other.xMult,
      bonusGold: bonusGold + other.bonusGold,
      specialEffects: mergedSpecial,
      log: [...log, ...other.log],
    );
  }
}

class ItemEffectResolver {
  // ═══════════════════════════════════════
  //  패시브 스킬 효과 해석 (29개)
  // ═══════════════════════════════════════

  static ItemEffectResult resolvePassives({
    required List<String> ownedPassiveIds,
    required List<CardInstance> playerCaptured,
    required RoundState round,
    required RunState run,
  }) {
    int totalChips = 0;
    double totalMult = 0.0;
    double totalXMult = 1.0;
    int totalBonusGold = 0;
    final Map<String, dynamic> specials = {};
    final List<String> logEntries = [];

    for (final id in ownedPassiveIds) {
      final item = findCatalogItem(id);
      if (item == null) continue;

      switch (id) {
        // ─── COMMON (10) ───
        case 'ps_spring_breeze':
          final count = playerCaptured.where(
            (c) => c.def.month >= 1 && c.def.month <= 3,
          ).length;
          final bonus = count * 3;
          if (bonus > 0) {
            totalChips += bonus;
            logEntries.add('${item.emoji} ${item.nameKo}: +$bonus chips');
          }

        case 'ps_autumn_harvest':
          final count = playerCaptured.where(
            (c) => c.def.month >= 9 && c.def.month <= 11,
          ).length;
          final bonus = count * 3;
          if (bonus > 0) {
            totalChips += bonus;
            logEntries.add('${item.emoji} ${item.nameKo}: +$bonus chips');
          }

        case 'ps_summer_heat':
          final count = playerCaptured.where(
            (c) => c.def.month >= 6 && c.def.month <= 8,
          ).length;
          final bonus = count * 3;
          if (bonus > 0) {
            totalChips += bonus;
            logEntries.add('${item.emoji} ${item.nameKo}: +$bonus chips');
          }

        case 'ps_winter_chill':
          final count = playerCaptured.where(
            (c) => c.def.month == 12,
          ).length;
          final bonus = count * 8;
          if (bonus > 0) {
            totalChips += bonus;
            logEntries.add('${item.emoji} ${item.nameKo}: +$bonus chips');
          }

        case 'ps_junk_collector':
          specials['junkThreshold'] = 8;
          logEntries.add('${item.emoji} ${item.nameKo}: junk threshold -> 8');

        case 'ps_coin_picker':
          // bonusGold는 점수 정산 시 별도 처리 (승리 시만)
          specials['coinPickerActive'] = true;
          specials['goldPerPoint'] = 5;

        case 'ps_insurance':
          specials['nagariReduction'] = 0.5;

        case 'ps_junk_luck':
          specials['junkBonusChance'] = 0.25;

        case 'ps_skilled_hand':
          specials['extraFlipChance'] = 0.15;

        case 'ps_bluff':
          specials['revealOpponentCards'] = 2;

        // ─── RARE (10) ───
        case 'ps_full_moon':
          final brightCount = playerCaptured.where(
            (c) => c.def.grade == CardGrade.bright,
          ).length;
          final bonus = brightCount * 0.5;
          if (bonus > 0) {
            totalMult += bonus;
            logEntries.add('${item.emoji} ${item.nameKo}: +${bonus.toStringAsFixed(1)} mult');
          }

        case 'ps_golden_eagle':
          final animalCount = playerCaptured.where(
            (c) => c.def.grade == CardGrade.animal,
          ).length;
          if (animalCount >= 5) {
            totalXMult *= 1.5;
            logEntries.add('${item.emoji} ${item.nameKo}: x1.5');
          }

        case 'ps_gambler':
          final goBonus = round.goCount * 1.0;
          if (goBonus > 0) {
            totalMult += goBonus;
            logEntries.add('${item.emoji} ${item.nameKo}: +${goBonus.toStringAsFixed(1)} mult');
          }

        case 'ps_nagari_memory':
          // 이전 판 패배 확인 (losses > 0 && winStreak == 0)
          final lostPrevious = run.losses > 0 && run.winStreak == 0;
          if (lostPrevious) {
            totalXMult *= 2.0;
            logEntries.add('${item.emoji} ${item.nameKo}: x2.0');
          }

        case 'ps_dark_horse':
          final brightCnt = playerCaptured.where(
            (c) => c.def.grade == CardGrade.bright,
          ).length;
          final animalCnt = playerCaptured.where(
            (c) => c.def.grade == CardGrade.animal,
          ).length;
          final ribbonCnt = playerCaptured.where(
            (c) => c.def.grade == CardGrade.ribbon,
          ).length;
          final junkCnt = playerCaptured.where(
            (c) => c.def.grade == CardGrade.junk,
          ).length;
          final counts = [brightCnt, animalCnt, ribbonCnt, junkCnt];
          final minCnt = counts.reduce((a, b) => a < b ? a : b);
          if (minCnt >= 1) {
            totalXMult *= 1.5;
            logEntries.add('${item.emoji} ${item.nameKo}: x1.5');
          }

        case 'ps_double_junk':
          specials['doubleJunkValue'] = 5;
          logEntries.add('${item.emoji} ${item.nameKo}: double junk = 5');

        case 'ps_comeback_king':
          if (round.playerScore < round.opponentScore) {
            totalXMult *= 1.5;
            logEntries.add('${item.emoji} ${item.nameKo}: x1.5 (behind)');
          } else if (round.playerScore > round.opponentScore) {
            totalXMult *= 0.8;
            logEntries.add('${item.emoji} ${item.nameKo}: x0.8 (ahead)');
          }

        case 'ps_flower_viewing':
          specials['doubleMatchBonus'] = 8;

        case 'ps_ribbon_weaver':
          final ribbonCount = playerCaptured.where(
            (c) => c.def.grade == CardGrade.ribbon,
          ).length;
          if (ribbonCount >= 4) {
            totalMult += 2.0;
            logEntries.add('${item.emoji} ${item.nameKo}: +2.0 mult');
          }

        case 'ps_sweep_master':
          final sweepBonus = round.sweepCount * 0.3;
          if (sweepBonus > 0) {
            totalMult += sweepBonus;
            logEntries.add('${item.emoji} ${item.nameKo}: +${sweepBonus.toStringAsFixed(1)} mult');
          }

        // ─── EPIC (5) ───
        case 'ps_rainy_season':
          specials['wildDecember'] = true;

        case 'ps_flower_rain':
          specials['junkToRibbonChance'] = 0.4;

        case 'ps_flower_bomb':
          specials['tripleHandXMult'] = 3.0;

        case 'ps_provoke':
          specials['provokeActive'] = true;

        case 'ps_ppuk_inducer':
          specials['ppukBonusSteal'] = 2;

        // ─── LEGENDARY (4) ───
        case 'ps_legendary_tazza':
          totalXMult *= 2.0;
          logEntries.add('${item.emoji} ${item.nameKo}: x2.0');

        case 'ps_gamblers_instinct':
          specials['deckChoice'] = 2;

        case 'ps_time_rewind':
          specials['rewindAvailable'] = true;

        case 'ps_flower_lord':
          specials['cardReassign'] = true;

        // ─── SECRET ───
        case 'x_ogwang_crown':
          final brightCount = playerCaptured.where(
            (c) => c.def.grade == CardGrade.bright,
          ).length;
          if (brightCount >= 3) {
            totalXMult *= 2.0;
            logEntries.add('${item.emoji} ${item.nameKo}: x2.0');
          }
      }
    }

    return ItemEffectResult(
      chips: totalChips,
      mult: totalMult,
      xMult: totalXMult,
      bonusGold: totalBonusGold,
      specialEffects: specials,
      log: logEntries,
    );
  }

  // ═══════════════════════════════════════
  //  부적 효과 해석
  // ═══════════════════════════════════════

  static ItemEffectResult resolveTalismans({
    required List<String> ownedTalismanIds,
    required RoundState round,
    required RunState run,
  }) {
    int totalChips = 0;
    double totalMult = 0.0;
    double totalXMult = 1.0;
    int totalBonusGold = 0;
    final Map<String, dynamic> specials = {};
    final List<String> logEntries = [];

    for (final id in ownedTalismanIds) {
      final item = findCatalogItem(id);
      if (item == null) continue;

      switch (id) {
        case 't_lucky_coin':
          specials['shopDiscount'] = 0.2;

        case 't_gambler_soul':
          // 3고 이상 시 +0.5~2.0 mult
          if (round.goCount >= 3) {
            final bonusMult = (0.5 + 0.5 * (round.goCount - 3)).clamp(0.5, 2.0);
            totalMult += bonusMult;
            logEntries.add('${item.emoji} ${item.nameKo}: +${bonusMult.toStringAsFixed(1)} mult');
          }

        case 't_mountain_charm':
          // 동물 카드 점수 x1.5 (별도 계산은 ScoreCalculator에서)
          specials['animalXMult'] = 1.5;
          logEntries.add('${item.emoji} ${item.nameKo}: animal x1.5');

        case 't_moonlight_pouch':
          specials['bonusCardAtStart'] = 1;

        case 't_dokkaebi_mallet':
          specials['junkGoldChance'] = 0.1;
          specials['junkGoldAmount'] = 2;

        case 't_samshin_granny':
          specials['giftCommonPassive'] = true;

        case 't_cheaters_glove':
          specials['matchFailReturn'] = true;

        case 't_golden_mat':
          specials['victoryGoldBonus'] = 0.15;

        case 't_gwangbak_shield':
          specials['nullifyGwangbak'] = true;
      }
    }

    return ItemEffectResult(
      chips: totalChips,
      mult: totalMult,
      xMult: totalXMult,
      bonusGold: totalBonusGold,
      specialEffects: specials,
      log: logEntries,
    );
  }

  // ═══════════════════════════════════════
  //  소모품 효과 해석 (라운드 시작 시)
  // ═══════════════════════════════════════

  static ItemEffectResult resolveConsumables({
    required List<String> equippedIds,
    required RoundState round,
  }) {
    double totalXMult = 1.0;
    final Map<String, dynamic> specials = {};
    final List<String> logEntries = [];

    for (final id in equippedIds) {
      final item = findCatalogItem(id);
      if (item == null) continue;

      switch (id) {
        case 'c_gwang_scanner':
        case 'P-001':
          specials['gwangScannerActive'] = true;

        case 'c_safety_helmet':
        case 'P-002':
          specials['bankruptcyShield'] = true;

        case 'c_jackpot_ticket':
        case 'P-003':
          totalXMult *= 5.0;
          logEntries.add('${item.emoji} ${item.nameKo}: x5.0');

        case 'c_pi_magnet':
          specials['bonusJunkOnCapture'] = 1;

        case 'c_ribbon_polish':
          specials['doubleRibbonScore'] = true;
          totalXMult *= 1.0; // 리본 점수만 2배 (별도 처리)
          logEntries.add('${item.emoji} ${item.nameKo}: ribbon x2');

        case 'c_bomb_fuse':
          specials['bombFuseXMult'] = 4.0;
      }
    }

    return ItemEffectResult(
      xMult: totalXMult,
      specialEffects: specials,
      log: logEntries,
    );
  }

  // ═══════════════════════════════════════
  //  시너지 보너스 해석
  // ═══════════════════════════════════════

  static ItemEffectResult resolveSynergies({
    required List<String> allOwnedItemIds,
  }) {
    int totalChips = 0;
    double totalMult = 0.0;
    double totalXMult = 1.0;
    final Map<String, dynamic> specials = {};
    final List<String> logEntries = [];

    // 태그 시너지
    final activeSynergies = getActiveTagSynergies(allOwnedItemIds);
    for (final syn in activeSynergies) {
      totalChips += syn.bonusChips;
      totalMult += syn.bonusMult;
      if (syn.bonusXMult != 1.0) {
        totalXMult *= syn.bonusXMult;
      }

      // 특수 시너지 효과
      switch (syn.id) {
        case 'syn_junk_empire':
          specials['junkThresholdReduction'] = 1;
        case 'syn_tycoon':
          specials['synergyShopDiscount'] = 0.1;
        case 'syn_fortress':
          specials['bakPenaltyReduction'] = 0.25;
      }

      if (syn.bonusChips > 0 || syn.bonusMult > 0 || syn.bonusXMult != 1.0) {
        final parts = <String>[];
        if (syn.bonusChips > 0) parts.add('+${syn.bonusChips} chips');
        if (syn.bonusMult > 0) parts.add('+${syn.bonusMult.toStringAsFixed(1)} mult');
        if (syn.bonusXMult != 1.0) parts.add('x${syn.bonusXMult.toStringAsFixed(1)}');
        logEntries.add('[${syn.nameKo}] ${parts.join(', ')}');
      }
    }

    // 숨겨진 시너지
    final activeHidden = getActiveHiddenSynergies(allOwnedItemIds);
    for (final hidden in activeHidden) {
      totalChips += hidden.bonusChips;
      totalMult += hidden.bonusMult;
      if (hidden.bonusXMult != 1.0) {
        totalXMult *= hidden.bonusXMult;
      }

      // 특수 숨겨진 시너지 효과
      if (hidden.id == 'syn_moonlight') {
        specials['brightCaptureGold'] = 10;
      }

      final parts = <String>[];
      if (hidden.bonusChips > 0) parts.add('+${hidden.bonusChips} chips');
      if (hidden.bonusMult > 0) parts.add('+${hidden.bonusMult.toStringAsFixed(1)} mult');
      if (hidden.bonusXMult != 1.0) parts.add('x${hidden.bonusXMult.toStringAsFixed(1)}');
      if (parts.isNotEmpty) {
        logEntries.add('[${hidden.nameKo}] ${parts.join(', ')}');
      }
    }

    return ItemEffectResult(
      chips: totalChips,
      mult: totalMult,
      xMult: totalXMult,
      specialEffects: specials,
      log: logEntries,
    );
  }

  // ═══════════════════════════════════════
  //  전체 통합 해석 (ScoreCalculator에서 호출)
  // ═══════════════════════════════════════

  static ItemEffectResult resolveAll({
    required RunState run,
    required RoundState round,
    required List<CardInstance> playerCaptured,
  }) {
    final passiveResult = resolvePassives(
      ownedPassiveIds: run.ownedPassiveIds,
      playerCaptured: playerCaptured,
      round: round,
      run: run,
    );

    final talismanResult = resolveTalismans(
      ownedTalismanIds: run.ownedTalismanIds,
      round: round,
      run: run,
    );

    final consumableResult = resolveConsumables(
      equippedIds: run.equippedRoundItemIds,
      round: round,
    );

    final synergyResult = resolveSynergies(
      allOwnedItemIds: run.allOwnedItemIds,
    );

    return passiveResult
        .merge(talismanResult)
        .merge(consumableResult)
        .merge(synergyResult);
  }
}
