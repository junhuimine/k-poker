// K-Poker -- 시너지 평가기 (카드 에디션 효과 전용)
//
// 카드 에디션(Foil, Holographic, Polychrome)의 보너스를 계산.
// 개별 아이템의 chips/mult/xMult 효과는 ItemEffectResolver에서 단일 소스로 처리.

import '../models/card_def.dart';
import '../data/item_catalog.dart';

class SynergyChain {
  final int chips;
  final double mult;
  final List<String> log;

  SynergyChain({required this.chips, required this.mult, required this.log});
}

class SynergyEvaluator {
  /// 카드 에디션 효과만 적용 (Foil/Holo/Poly)
  /// ownedPassives는 하위 호환을 위해 파라미터로 유지하되 사용하지 않음.
  static SynergyChain evaluate({
    required int baseChips,
    required double baseMult,
    required List<CardInstance> capturedCards,
    required List<ItemDef> ownedPassives,
  }) {
    int currentChips = baseChips;
    double currentMult = baseMult;
    List<String> synerLog = [];

    // 1. 카드 에디션 가산 효과 (Foil: +Chips, Holographic: +Mult)
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

    // 2. 카드 에디션 승산 효과 (Polychrome: x1.5 Mult)
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
