// 🎴 K-Poker — 시너지 평가기 (Balatro Synergy Chain)
//
// 스킬 카드와 카드 에디션의 좌->우 체인을 계산하여
// 최종적인 Chips와 Mult를 산출하는 고도의 연산 모듈.

import '../models/card_def.dart';
import '../data/skills.dart';

class SynergyChain {
  final int chips;
  final double mult;
  final List<String> log;

  SynergyChain({required this.chips, required this.mult, required this.log});
}

class SynergyEvaluator {
  /// 기본 점수와 멀티플라이어를 입력받아 스킬 체인을 적용
  static SynergyChain evaluate({
    required int baseChips,
    required double baseMult,
    required List<CardInstance> capturedCards,
    required List<SkillDef> activeSkills,
  }) {
    int currentChips = baseChips;
    double currentMult = baseMult;
    List<String> synerLog = [];

    // 1. 카드 레벨 효과 적용 (Card Editions) — 가산 계열
    for (var card in capturedCards) {
      if (card.edition == Edition.foil) {
        currentChips += 50;
        synerLog.add('${card.def.nameKo} (Foil): +50 Chips');
      }
      if (card.edition == Edition.holographic) {
        currentMult += 10.0;
        synerLog.add('${card.def.nameKo} (Holo): +10 Mult');
      }
    }

    // 2. 스킬 체인 적용 (좌 -> 우 순서)
    // * Balatro처럼 가산(+Mult)을 먼저 하고 승산(xMult)을 나중에 하는 것이 전략의 핵심
    // Phase A: 가산 계열 (foundation, scaling +Chips/+Mult)
    for (var skill in activeSkills) {
      final effect = _getAdditiveEffect(skill, capturedCards);
      if (effect != null) {
        currentChips += effect.chips;
        currentMult += effect.mult;
        if (effect.chips > 0 || effect.mult > 0) {
          final parts = <String>[];
          if (effect.chips > 0) parts.add('+${effect.chips} Chips');
          if (effect.mult > 0) parts.add('+${effect.mult.toStringAsFixed(1)} Mult');
          synerLog.add('${skill.emoji} ${skill.nameKo}: ${parts.join(', ')}');
        }
      }
    }

    // Phase B: 승산 계열 (explosion xMult) — 가장 마지막에 배치할수록 효과 극대화
    for (var skill in activeSkills) {
      final xMult = _getMultiplicativeEffect(skill, capturedCards);
      if (xMult != null && xMult != 1.0) {
        currentMult *= xMult;
        synerLog.add('${skill.emoji} ${skill.nameKo}: x${xMult.toStringAsFixed(1)} Mult');
      }
    }

    // 3. 카드 레벨의 승산(xMult) 효과 최종 적용 (Polychrome)
    for (var card in capturedCards) {
      if (card.edition == Edition.polychrome) {
        currentMult *= 1.5;
        synerLog.add('${card.def.nameKo} (Poly): x1.5 Mult');
      }
    }

    return SynergyChain(
      chips: currentChips,
      mult: currentMult,
      log: synerLog,
    );
  }

  /// 가산 효과 계산 (+ Chips, + Mult) — foundation / scaling / economy / utility
  static _AdditiveEffect? _getAdditiveEffect(
    SkillDef skill,
    List<CardInstance> capturedCards,
  ) {
    switch (skill.id) {
      // ═══════════════════════════════════════
      //  COMMON — foundation
      // ═══════════════════════════════════════

      case 'spring_breeze': // 봄바람: 1~3월 매칭 시 점수 +2
        final springCards = capturedCards.where(
          (c) => c.def.month >= 1 && c.def.month <= 3,
        ).length;
        return _AdditiveEffect(chips: springCards * 2, mult: 0);

      case 'autumn_harvest': // 가을걷이: 9~11월 매칭 시 점수 +2
        final autumnCards = capturedCards.where(
          (c) => c.def.month >= 9 && c.def.month <= 11,
        ).length;
        return _AdditiveEffect(chips: autumnCards * 2, mult: 0);

      case 'junk_collector': // 피 수집가: 피 필요 장수 10→8 (rule bend, 칩 보너스로 근사)
        final junkCount = capturedCards.where(
          (c) => c.def.grade == CardGrade.junk,
        ).length;
        // 8~9장일 때 보너스로 피 점수 보상 (10장 미만이라 ScoreCalculator에서 안 줌)
        if (junkCount >= 8 && junkCount < 10) {
          return _AdditiveEffect(chips: 1 + (junkCount - 8), mult: 0);
        }
        return _AdditiveEffect(chips: 10, mult: 1); // 기본 보너스

      case 'keen_eye': // 눈썰미: 덱 미리보기 (UI 레이어 처리)
        return _AdditiveEffect(chips: 5, mult: 0);

      case 'quick_wrist': // 빠른 손목: 매칭 실패 시 복귀 (게임플레이 효과)
        return _AdditiveEffect(chips: 5, mult: 0);

      case 'skilled_hand': // 노련한 손: 15% 추가 뒤집기 (게임플레이 효과)
        return _AdditiveEffect(chips: 10, mult: 1);

      case 'coin_picker': // 동전 줍기: 경제 효과 (점수 -> 금화)
        return _AdditiveEffect(chips: 5, mult: 0);

      case 'bottom_deal': // 밑장 빼기: 덱 맨 아래 선택 가능 (게임플레이 효과)
        return _AdditiveEffect(chips: 8, mult: 0);

      case 'card_laundry': // 카드 세탁: 바닥 카드 되돌리기 (게임플레이 효과)
        return _AdditiveEffect(chips: 5, mult: 0);

      case 'bluff': // 허세: 상대 패 엿보기 (게임플레이 효과)
        return _AdditiveEffect(chips: 5, mult: 0);

      case 'insurance': // 보험: 나가리 손실 감소 (경제 효과)
        return _AdditiveEffect(chips: 5, mult: 0);

      case 'junk_luck': // 둑배기: 피 매칭 시 추가 피 (게임플레이 효과)
        final junkCaptured = capturedCards.where(
          (c) => c.def.grade == CardGrade.junk,
        ).length;
        return _AdditiveEffect(chips: (junkCaptured * 0.5).floor(), mult: 0);

      // ═══════════════════════════════════════
      //  RARE — scaling (+Chips/+Mult)
      // ═══════════════════════════════════════

      case 'full_moon': // 보름달: 광 먹을 때마다 멀티 +0.5
        final brightCount = capturedCards.where(
          (c) => c.def.grade == CardGrade.bright,
        ).length;
        return _AdditiveEffect(chips: 0, mult: brightCount * 0.5);

      case 'flower_viewing': // 꽃놀이: 같은 턴 2회 매칭 → 보너스 +5
        return _AdditiveEffect(chips: 30, mult: 3);

      case 'gambler': // 승부사: Go 선언마다 멀티 +1 (go 처리는 ScoreCalculator)
        return _AdditiveEffect(chips: 20, mult: 3);

      case 'nagari_memory': // 나가리의 기억: 이전 실패 시 이번 판 멀티 +100%
        return _AdditiveEffect(chips: 0, mult: 3);

      case 'tazza_eye': // 타짜의 눈: 덱 3장 미리보기 (게임플레이 효과)
        return _AdditiveEffect(chips: 30, mult: 3);

      case 'double_junk_master': // 쌍피 마스터: 쌍피 5장 계산
        final doubleJunks = capturedCards.where(
          (c) => c.def.doubleJunk,
        ).length;
        return _AdditiveEffect(chips: doubleJunks * 5, mult: 0);

      case 'comeback_king': // 역전의 명수: 뒤질 때 점수 x1.5 (승산으로 처리)
        return _AdditiveEffect(chips: 30, mult: 3);

      case 'golden_eagle': // 금독수리: 동물 5+ 시 보너스 (승산으로 처리)
        final animalCount = capturedCards.where(
          (c) => c.def.grade == CardGrade.animal,
        ).length;
        if (animalCount >= 5) {
          return _AdditiveEffect(chips: 40, mult: 3);
        }
        return _AdditiveEffect(chips: 0, mult: 0); // 4장 이하 -2 (승산에서 처리)

      case 'flower_storm': // 꽃보라: 인접 월 카드 흡수 (게임플레이 효과)
        return _AdditiveEffect(chips: 30, mult: 3);

      // ═══════════════════════════════════════
      //  EPIC — explosion (가산 부분)
      // ═══════════════════════════════════════

      case 'trick': // 속임수: 바닥 카드 월 변경 (게임플레이 효과)
        return _AdditiveEffect(chips: 50, mult: 5);

      case 'flower_bomb': // 꽃폭탄: 3장 같은 월 → 4장 풀매칭 +x3
        return _AdditiveEffect(chips: 80, mult: 5);

      case 'provoke': // 도발: 핸드 3장 공개 → x3
        return _AdditiveEffect(chips: 50, mult: 5);

      case 'rainy_season': // 장마철: 비(12월) 카드 만능 매칭
        final rainCards = capturedCards.where(
          (c) => c.def.month == 12,
        ).length;
        return _AdditiveEffect(chips: 50 + rainCards * 10, mult: 5);

      case 'flower_rain': // 꽃비: 피 → 띠 승격 확률 (게임플레이 효과)
        return _AdditiveEffect(chips: 60, mult: 5);

      case 'ppuk_inducer': // 뻑 유도: 상대에게 뻑 강제 (게임플레이 효과)
        return _AdditiveEffect(chips: 50, mult: 5);

      // ═══════════════════════════════════════
      //  LEGENDARY — explosion (가산 부분)
      // ═══════════════════════════════════════

      case 'legendary_tazza': // 전설의 타짜: 모든 멀티 x2 (승산에서 처리)
        return _AdditiveEffect(chips: 100, mult: 10);

      case 'gamblers_instinct': // 도박꾼의 직감: 카드 2장 중 선택
        return _AdditiveEffect(chips: 100, mult: 10);

      case 'time_rewind': // 시간 되감기: 3턴 전으로 되돌리기
        return _AdditiveEffect(chips: 100, mult: 10);

      case 'flower_lord': // 꽃패의 주인: 먹은 카드 월 재배치
        return _AdditiveEffect(chips: 100, mult: 10);

      default:
        // 등급별 기본 보너스 (알 수 없는 스킬 대비)
        return _getDefaultAdditiveByRarity(skill.rarity);
    }
  }

  /// 승산 효과 계산 (x Mult) — explosion 계열
  static double? _getMultiplicativeEffect(
    SkillDef skill,
    List<CardInstance> capturedCards,
  ) {
    switch (skill.id) {
      // ═══════════════════════════════════════
      //  RARE — scaling (조건부 xMult)
      // ═══════════════════════════════════════

      case 'dark_horse': // 다크호스: 가장 적게 먹은 카테고리 x2
        // 4개 카테고리 중 가장 적은 것의 카운트로 판단
        final brightCnt = capturedCards.where(
          (c) => c.def.grade == CardGrade.bright,
        ).length;
        final animalCnt = capturedCards.where(
          (c) => c.def.grade == CardGrade.animal,
        ).length;
        final ribbonCnt = capturedCards.where(
          (c) => c.def.grade == CardGrade.ribbon,
        ).length;
        final junkCnt = capturedCards.where(
          (c) => c.def.grade == CardGrade.junk,
        ).length;
        final minCnt = [brightCnt, animalCnt, ribbonCnt, junkCnt]
            .reduce((a, b) => a < b ? a : b);
        // 최소 카테고리가 1장 이상이면 활성
        if (minCnt >= 1) return 1.5;
        return 1.0;

      case 'golden_eagle': // 금독수리: 동물 5+ x1.5, 4- x0.8
        final animalCount = capturedCards.where(
          (c) => c.def.grade == CardGrade.animal,
        ).length;
        return animalCount >= 5 ? 1.5 : 0.9;

      case 'comeback_king': // 역전의 명수: 뒤질 때 x1.5
        // 점수 비교는 상위에서 처리해야 하므로 기본 x1.3 적용
        return 1.3;

      case 'nagari_memory': // 나가리의 기억: 이전 실패 시 x2
        // 실패 여부는 상위에서 판단, 기본 x1.3 적용
        return 1.3;

      // ═══════════════════════════════════════
      //  EPIC — explosion (xMult)
      // ═══════════════════════════════════════

      case 'trick': // 속임수: x1.5
        return 1.5;

      case 'flower_bomb': // 꽃폭탄: x3.0
        return 3.0;

      case 'provoke': // 도발: x3.0 (리스크 포함)
        return 3.0;

      case 'rainy_season': // 장마철: x2.0
        return 2.0;

      case 'flower_rain': // 꽃비: x2.0
        return 2.0;

      case 'ppuk_inducer': // 뻑 유도: x2.0
        return 2.0;

      // ═══════════════════════════════════════
      //  LEGENDARY — explosion (xMult)
      // ═══════════════════════════════════════

      case 'legendary_tazza': // 전설의 타짜: 모든 멀티 x2
        return 3.0;

      case 'gamblers_instinct': // 도박꾼의 직감: x2.5
        return 2.5;

      case 'time_rewind': // 시간 되감기: x3.0
        return 3.0;

      case 'flower_lord': // 꽃패의 주인: x3.0
        return 3.0;

      default:
        return null; // 승산 효과 없음
    }
  }

  /// 등급별 기본 가산 보너스
  static _AdditiveEffect _getDefaultAdditiveByRarity(SkillRarity rarity) {
    switch (rarity) {
      case SkillRarity.common:
        return _AdditiveEffect(chips: 10, mult: 1);
      case SkillRarity.rare:
        return _AdditiveEffect(chips: 30, mult: 3);
      case SkillRarity.epic:
        return _AdditiveEffect(chips: 50, mult: 5);
      case SkillRarity.legendary:
        return _AdditiveEffect(chips: 100, mult: 10);
    }
  }
}

/// 가산 효과 데이터 클래스
class _AdditiveEffect {
  final int chips;
  final double mult;

  _AdditiveEffect({required this.chips, required this.mult});
}
