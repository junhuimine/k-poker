---
name: ui-widgets
description: K-Poker UI 위젯 및 화면 수정 시 사용. 게임 화면, 상점, 설정, 오버레이 등 Flutter 위젯 작업.
paths:
  - "lib/ui/**/*.dart"
  - "lib/state/**/*.dart"
  - "lib/i18n/**/*.dart"
---

K-Poker의 Flutter UI 위젯을 수정합니다.

## 현재 상태
- UI 분석: !`dart analyze lib/ui/ lib/state/ 2>&1 | head -5`
- 최근 UI 변경: !`git log --oneline -3 -- lib/ui/ lib/state/`

## 핵심 규칙
- Riverpod: `ref.watch` (빌드 시) vs `ref.read` (이벤트 핸들러) 구분 철저히
- 다국어 텍스트는 반드시 `AppStrings`를 통해 참조 (하드코딩 금지)
- 카드 위젯(`hwatu_card.dart`)은 스킨 시스템(`card_skin_provider.dart`)과 연동
- 애니메이션 오버레이 수정 시 기존 타이밍 보존

## 주요 파일
- `ui/game_screen.dart` — 메인 게임 화면
- `ui/shop_screen.dart` — 상점
- `ui/settings_overlay.dart` — 설정 오버레이
- `ui/widgets/hwatu_card.dart` — 화투 카드 위젯
- `ui/widgets/card_animation_overlay.dart` — 카드 애니메이션
- `state/game_providers.dart` — Riverpod 상태
- `i18n/app_strings.dart` — 다국어 문자열
