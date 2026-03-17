# 🗺️ CODEBASE_MAP.md — K-Poker

> 프로젝트의 구조와 파일별 역할 정의

## 1. Directory Structure

```
lib/
├── common/       # 공통 상수, 유틸리티
│   └── constants.dart
├── data/         # 정적 데이터 (카드 정의, 스킬 목록)
│   ├── all_cards.dart
│   └── skills.dart
├── engine/       # 순수 게임 로직 (UI 독립)
│   ├── card_matcher.dart    # 매칭 로직
│   ├── score_calculator.dart # 점수 계산 (예정)
│   └── game_engine.dart      # 전체 진행 (예정)
├── models/       # 데이터 모델
│   ├── card_def.dart
│   ├── round_state.dart
│   └── run_state.dart        # (예정)
├── state/        # Riverpod 상태 관리
│   └── game_providers.dart   # Notifiers (예정)
├── ui/           # Flutter 위젯 (화면, 컴포넌트)
└── main.dart     # 앱 엔트리 포인트
```

## 2. Core Logic Flow
1. **Match**: `card_matcher.dart`를 통해 필드와 핸드/덱 카드 매칭
2. **Score**: 매칭된 카드를 기반으로 `score_calculator.dart`가 Chips/Mult 계산
3. **Turn**: `game_engine.dart`가 턴 교체 및 상태 업데이트 관리
4. **State**: Riverpod Providers가 UI에 상태 전파
