// 🎴 K-Poker — 기술 효과 엔진 (Balatro 스타일 시너지)
//
// 특정 기술이 점수 계산이나 게임 규칙에 미치는 영향을 정의.
// 각 스킬별 고유 효과를 개별 구현.

import '../data/skills.dart';
import 'score_calculator.dart';

/// 스킬 효과 적용 결과 (개별 스킬이 발동했는지 추적)
class SkillActivation {
  final String skillId;
  final String skillNameKo;
  final int chipBonus;
  final double multAdd;
  final double multMult; // 1.0 = 변화 없음
  final String description;

  const SkillActivation({
    required this.skillId,
    required this.skillNameKo,
    this.chipBonus = 0,
    this.multAdd = 0,
    this.multMult = 1.0,
    this.description = '',
  });

  bool get isActive => chipBonus > 0 || multAdd > 0 || multMult != 1.0;
}

class SkillEffects {
  /// 점수 계산 최종 단계에서 스킬 시너지 적용
  static ScoreResult applySkillSynergies(ScoreResult current, List<SkillDef> skills) {
    int totalChips = current.baseChips;
    double totalMult = current.multiplier;
    List<String> activeYaku = List.from(current.appliedYaku);

    // 스킬을 좌 -> 우 순서대로 적용 (Balatro 핵심 메커닉)
    // Phase 1: 가산 효과 (+Chips, +Mult)
    for (var skill in skills) {
      final activation = _resolveAdditiveSkill(skill);
      if (activation.isActive) {
        totalChips += activation.chipBonus;
        totalMult += activation.multAdd;
        activeYaku.add('${skill.emoji} ${activation.description}');
      }
    }

    // Phase 2: 승산 효과 (xMult) — 마지막에 적용하여 극대화
    for (var skill in skills) {
      final activation = _resolveMultiplicativeSkill(skill);
      if (activation.multMult != 1.0) {
        totalMult *= activation.multMult;
        activeYaku.add('${skill.emoji} ${activation.description}');
      }
    }

    return ScoreResult(
      baseChips: totalChips,
      multiplier: totalMult,
      finalScore: (totalChips * totalMult).floor(),
      appliedYaku: activeYaku,
    );
  }

  /// 개별 스킬의 가산 효과 해석
  static SkillActivation _resolveAdditiveSkill(SkillDef skill) {
    switch (skill.id) {
      // ═══ COMMON (foundation) ═══
      case 'spring_breeze':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 15, multAdd: 1,
          description: '봄바람: +15 Chips, +1 Mult',
        );
      case 'autumn_harvest':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 15, multAdd: 1,
          description: '가을걷이: +15 Chips, +1 Mult',
        );
      case 'junk_collector':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 10, multAdd: 1,
          description: '피 수집가: +10 Chips, +1 Mult',
        );
      case 'keen_eye':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 5,
          description: '눈썰미: +5 Chips (유틸리티)',
        );
      case 'quick_wrist':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 5,
          description: '빠른 손목: +5 Chips (유틸리티)',
        );
      case 'skilled_hand':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 10, multAdd: 1,
          description: '노련한 손: +10 Chips, +1 Mult',
        );
      case 'coin_picker':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 5,
          description: '동전 줍기: +5 Chips (경제)',
        );
      case 'bottom_deal':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 8,
          description: '밑장 빼기: +8 Chips (유틸리티)',
        );
      case 'card_laundry':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 5,
          description: '카드 세탁: +5 Chips (유틸리티)',
        );
      case 'bluff':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 5,
          description: '허세: +5 Chips (유틸리티)',
        );
      case 'insurance':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 5,
          description: '보험: +5 Chips (경제)',
        );
      case 'junk_luck':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 12, multAdd: 1,
          description: '둑배기: +12 Chips, +1 Mult',
        );

      // ═══ RARE (scaling) ═══
      case 'full_moon':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 30, multAdd: 3,
          description: '보름달: +30 Chips, +3 Mult',
        );
      case 'flower_viewing':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 35, multAdd: 3,
          description: '꽃놀이: +35 Chips, +3 Mult',
        );
      case 'gambler':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 30, multAdd: 3,
          description: '승부사: +30 Chips, +3 Mult',
        );
      case 'nagari_memory':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 40, multAdd: 3,
          description: '나가리의 기억: +40 Chips, +3 Mult',
        );
      case 'dark_horse':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 35, multAdd: 3,
          description: '다크호스: +35 Chips, +3 Mult',
        );
      case 'golden_eagle':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 40, multAdd: 3,
          description: '금독수리: +40 Chips, +3 Mult',
        );
      case 'flower_storm':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 35, multAdd: 3,
          description: '꽃보라: +35 Chips, +3 Mult',
        );
      case 'tazza_eye':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 50, multAdd: 3,
          description: '타짜의 눈: +50 Chips, +3 Mult',
        );
      case 'double_junk_master':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 30, multAdd: 3,
          description: '쌍피 마스터: +30 Chips, +3 Mult',
        );
      case 'comeback_king':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 40, multAdd: 3,
          description: '역전의 명수: +40 Chips, +3 Mult',
        );

      // ═══ EPIC (explosion — 가산 부분) ═══
      case 'trick':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 50, multAdd: 5,
          description: '속임수: +50 Chips, +5 Mult',
        );
      case 'flower_bomb':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 80, multAdd: 5,
          description: '꽃폭탄: +80 Chips, +5 Mult',
        );
      case 'provoke':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 60, multAdd: 5,
          description: '도발: +60 Chips, +5 Mult',
        );
      case 'rainy_season':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 70, multAdd: 5,
          description: '장마철: +70 Chips, +5 Mult',
        );
      case 'flower_rain':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 60, multAdd: 5,
          description: '꽃비: +60 Chips, +5 Mult',
        );
      case 'ppuk_inducer':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 55, multAdd: 5,
          description: '뻑 유도: +55 Chips, +5 Mult',
        );

      // ═══ LEGENDARY (explosion — 가산 부분) ═══
      case 'legendary_tazza':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 100, multAdd: 10,
          description: '전설의 타짜: +100 Chips, +10 Mult',
        );
      case 'gamblers_instinct':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 100, multAdd: 10,
          description: '도박꾼의 직감: +100 Chips, +10 Mult',
        );
      case 'time_rewind':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 100, multAdd: 10,
          description: '시간 되감기: +100 Chips, +10 Mult',
        );
      case 'flower_lord':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          chipBonus: 100, multAdd: 10,
          description: '꽃패의 주인: +100 Chips, +10 Mult',
        );

      default:
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
        );
    }
  }

  /// 개별 스킬의 승산 효과 해석 (xMult)
  static SkillActivation _resolveMultiplicativeSkill(SkillDef skill) {
    switch (skill.id) {
      // ═══ EPIC — explosion (xMult) ═══
      case 'trick':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 1.5,
          description: '속임수: x1.5 Mult',
        );
      case 'flower_bomb':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 3.0,
          description: '꽃폭탄: x3.0 Mult',
        );
      case 'provoke':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 3.0,
          description: '도발: x3.0 Mult',
        );
      case 'rainy_season':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 2.0,
          description: '장마철: x2.0 Mult',
        );
      case 'flower_rain':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 2.0,
          description: '꽃비: x2.0 Mult',
        );
      case 'ppuk_inducer':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 2.0,
          description: '뻑 유도: x2.0 Mult',
        );

      // ═══ RARE — scaling (조건부 xMult) ═══
      case 'dark_horse':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 1.5,
          description: '다크호스: x1.5 Mult',
        );
      case 'golden_eagle':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 1.5,
          description: '금독수리: x1.5 Mult',
        );
      case 'comeback_king':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 1.3,
          description: '역전의 명수: x1.3 Mult',
        );
      case 'nagari_memory':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 1.3,
          description: '나가리의 기억: x1.3 Mult',
        );

      // ═══ LEGENDARY — explosion (xMult) ═══
      case 'legendary_tazza':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 3.0,
          description: '전설의 타짜: x3.0 Mult',
        );
      case 'gamblers_instinct':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 2.5,
          description: '도박꾼의 직감: x2.5 Mult',
        );
      case 'time_rewind':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 3.0,
          description: '시간 되감기: x3.0 Mult',
        );
      case 'flower_lord':
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 3.0,
          description: '꽃패의 주인: x3.0 Mult',
        );

      default:
        return SkillActivation(
          skillId: skill.id, skillNameKo: skill.nameKo,
          multMult: 1.0, // 승산 효과 없음
        );
    }
  }
}
