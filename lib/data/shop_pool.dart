/// K-Poker -- 상점 아이템 풀 (확률, 슬롯 수, 비밀 해금)
///
/// 스테이지별 희귀도 가중치와 상점 슬롯 수를 결정.
/// 비밀 아이템의 해금 조건도 여기서 관리.
library;

import '../models/run_state.dart';
import 'item_catalog.dart';

class ShopPool {
  /// 스테이지별 희귀도 가중치 (확률 분포)
  ///
  /// stage 1-2: Common 위주
  /// stage 3-4: Rare 증가
  /// stage 5+:  Epic/Legendary 출현
  static Map<Rarity, double> getRarityWeights(int stage) {
    if (stage <= 1) {
      return {
        Rarity.common: 0.70,
        Rarity.rare: 0.25,
        Rarity.epic: 0.05,
        Rarity.legendary: 0.0,
        Rarity.secret: 0.0,
      };
    } else if (stage <= 2) {
      return {
        Rarity.common: 0.55,
        Rarity.rare: 0.30,
        Rarity.epic: 0.12,
        Rarity.legendary: 0.03,
        Rarity.secret: 0.0,
      };
    } else if (stage <= 3) {
      return {
        Rarity.common: 0.40,
        Rarity.rare: 0.30,
        Rarity.epic: 0.20,
        Rarity.legendary: 0.08,
        Rarity.secret: 0.02,
      };
    } else if (stage <= 4) {
      return {
        Rarity.common: 0.25,
        Rarity.rare: 0.30,
        Rarity.epic: 0.25,
        Rarity.legendary: 0.15,
        Rarity.secret: 0.05,
      };
    } else {
      // stage 5+
      return {
        Rarity.common: 0.15,
        Rarity.rare: 0.25,
        Rarity.epic: 0.30,
        Rarity.legendary: 0.20,
        Rarity.secret: 0.10,
      };
    }
  }

  /// 스테이지별 상점 슬롯 수
  static int getSlotCount(int stage) => stage >= 4 ? 4 : 3;

  /// 비밀 아이템 해금 조건
  static final Map<String, bool Function(RunState)> secretConditions = {
    'x_ogwang_crown': (run) {
      // 해금 조건: 오광 1회 달성 (highestScore 기반 또는 별도 플래그)
      // 현재는 최고 점수 15점 이상으로 대체 (오광 = 15점)
      return run.highestScore >= 15;
    },
  };

  /// 비밀 아이템이 해금되었는지 확인
  static bool isSecretUnlocked(String itemId, RunState run) {
    final condition = secretConditions[itemId];
    if (condition == null) return false;
    return condition(run);
  }

  /// 현재 상점에 표시 가능한 비밀 아이템 ID 목록
  static List<String> getUnlockedSecretIds(RunState run) {
    return secretConditions.entries
        .where((e) => e.value(run))
        .map((e) => e.key)
        .toList();
  }
}
