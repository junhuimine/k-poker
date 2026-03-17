// 🎴 K-Poker — 기술 효과 엔진 (Balatro 스타일 시너지)
//
// 특정 기술이 점수 계산이나 게임 규칙에 미치는 영향을 정의.

import '../data/skills.dart';
import 'score_calculator.dart';

class SkillEffects {
  /// 점수 계산 최종 단계에서 스킬 시너지 적용
  static ScoreResult applySkillSynergies(ScoreResult current, List<SkillDef> skills) {
    int totalChips = current.baseChips;
    double totalMult = current.multiplier;
    List<String> activeYaku = List.from(current.appliedYaku);

    // 스킬을 좌 -> 우 순서대로 적용 (Balatro 핵심 메커닉)
    for (var skill in skills) {
      switch (skill.id) {
        case 'keen_eye':
          // 규칙 왜곡: 덱 미리보기 (UI/Engine 레이어에서 처리)
          break;
        
        case 'full_moon':
          // 광 1장당 +1G 보너스 (경제 스킬)
          break;
          
        case 'junk_collector':
          // 피 9장부터 점수 획득 -> 이미 ScoreCalculator에서 junkCount >= 10 조건이므로 
          // 이 스킬이 있으면 로직이 변경되어야 함. (이런 것이 Rule Bending)
          break;
          
        // --- 커스텀 시너지 예시 ---
        case 'fire_starter':
          // 모든 불꽃패(Fire Enhancement)는 Mult +5
          totalMult += 5.0;
          activeYaku.add('불꽃 시너지');
          break;

        case 'multiplier_madness':
          // 현재 Mult가 10 이상이면 Mult x2
          if (totalMult >= 10.0) {
            totalMult *= 2.0;
            activeYaku.add('멀티 광기');
          }
          break;
      }
    }

    return ScoreResult(
      baseChips: totalChips,
      multiplier: totalMult,
      finalScore: (totalChips * totalMult).floor(),
      appliedYaku: activeYaku,
    );
  }
}
