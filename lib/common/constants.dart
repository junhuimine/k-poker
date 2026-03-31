/// 🎴 K-Poker — 공통 상수
/// 
/// 게임 전반에서 사용하는 딜레이, 크기, 패턴 등.
library;

/// 애니메이션 딜레이 (밀리초)
class AnimDuration {
  static const int cardMove = 800;      // 카드 이동 (손→필드→획득)
  static const int cardDeal = 600;      // 딜링 시 각 카드
  static const int cardFlip = 400;      // 카드 뒤집기
  static const int matchGlow = 500;     // 매칭 반짝임
  static const int dealInterval = 150;  // 딜링 카드 간 간격
}

/// 카드 크기 (논리 픽셀)
class CardSize {
  static const double normalWidth = 60;
  static const double normalHeight = 90;
  static const double smallWidth = 45;
  static const double smallHeight = 67;
}

/// 딜링 규칙 (2인 맞고 공식: 50장 = 바닥8 + 핸드10x2 + 덱22)
class DealRules {
  static const int handSize = 10;
  static const int fieldSize = 8;
}

/// 스테이지 테이블
class StageInfo {
  final int stage;
  final int opponentGold;
  final String name;
  const StageInfo(this.stage, this.opponentGold, this.name);
}

const List<StageInfo> stageTable = [
  StageInfo(1, 15, '동네 양아치'),
  StageInfo(2, 25, '골목 타짜'),
  StageInfo(3, 40, '도박장 고수'),
  StageInfo(4, 60, '전설의 꾼'),
  StageInfo(5, 90, '어둠의 제왕'),
];
