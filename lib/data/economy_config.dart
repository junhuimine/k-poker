/// K-Poker -- 골드 이코노미 상수
///
/// 골드 관련 모든 상수를 한 곳에서 관리.
/// itch.io 버전: 광고 없이 순수 인게임 경제만.
library;

class EconomyConfig {
  /// 새 게임 시작 시 초기 골드
  static const int startingGold = 50;

  /// 점수 1점당 기본 골드 (로케일 무관 고정값)
  /// 1회 승리 ≈ 60G (Common 90G보다 약간 부족 → 선택의 긴장감)
  static const int goldPerPoint = 12;

  /// 스테이지당 골드 수입 증가율 (0% = 플랫)
  static const double stageGoldScaling = 0.0;

  /// 상점 리롤 기본 비용
  static const int baseRerollCost = 50;

  /// 리롤 비용 증가분 (회당)
  static const int rerollCostIncrement = 25;

  /// 연승 보너스 발동 간격 (N연승마다)
  static const int winStreakBonusInterval = 3;

  /// 연승 보너스 골드
  static const int winStreakBonusGold = 50;

  /// 패배 시 골드 손실 없음 (판돈 money만 손실)
  /// 나가리도 골드 손실 없음 — 골드는 "모으기만 하는" 보상 자원

  /// 스테이지별 실효 goldPerPoint 계산
  static int effectiveGoldPerPoint(int stage) =>
      (goldPerPoint * (1 + (stage - 1) * stageGoldScaling)).round();
}
