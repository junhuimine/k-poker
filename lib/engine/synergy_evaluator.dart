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

    // 1. 카드 레벨 효과 적용 (Card Editions)
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
    for (var skill in activeSkills) {
      // 가산 계열 기술 (+Chips, +Mult)
      if (skill.category == SkillCategory.foundation) {
        if (skill.id == 'keen_eye') continue; // 유틸리티
        currentChips += 20; // 예시 기본 가산
        currentMult += 2.0;
        synerLog.add('${skill.nameKo}: +20 Chips, +2 Mult');
      }

      // 승산 계열 기술 (xMult) - 가장 마지막에 배치할수록 효과 극대화
      if (skill.category == SkillCategory.explosion) {
        currentMult *= 1.5;
        synerLog.add('${skill.nameKo}: x1.5 Mult');
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
}
