---
name: game-engine
description: K-Poker 게임 엔진 로직 수정 시 사용. 순수 게임 로직(카드 판정, 점수 계산, AI, 턴 진행)을 안전하게 수정.
paths:
  - "lib/engine/**/*.dart"
  - "lib/models/**/*.dart"
  - "lib/data/**/*.dart"
---

K-Poker 게임 엔진 코드를 수정합니다.

## 현재 상태
- 분석 결과: !`dart analyze lib/engine/ lib/models/ lib/data/ 2>&1 | head -5`
- 최근 변경: !`git log --oneline -3 -- lib/engine/ lib/models/ lib/data/`

## 핵심 규칙
- `lib/engine/`은 **순수 로직만** — `import 'package:flutter/'` 절대 금지
- Freezed 모델 변경 시 반드시 `dart run build_runner build --delete-conflicting-outputs` 실행
- 카드 판정 로직 변경 시 기존 테스트 먼저 확인
- `all_cards.dart`의 48장 카드 데이터 수정 시 전체 게임 영향 확인 필수

## 파일 구조
- `engine/game_engine.dart` — 메인 게임 루프, 턴 진행
- `models/card_def.dart` — 카드 정의 (Freezed)
- `models/run_state.dart` — 런 상태 (Freezed)
- `data/all_cards.dart` — 48장 카드 정적 데이터
- `data/stage_config.dart` — 스테이지 설정
