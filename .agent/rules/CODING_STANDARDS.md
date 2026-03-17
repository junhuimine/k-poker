# 📜 CODING_STANDARDS.md — K-Poker

> 프로젝트의 코드 품질 및 일관성을 위한 규칙

## 1. General Principles
- **No Hardcoding**: 모든 상수는 `constants.dart` 또는 데이터 정의 파일에서 관리.
- **Modularity**: 로직은 UI와 분리하여 `engine/` 레이어에 작성.
- **Immutability**: 모든 상태 모델은 `freezed`를 사용한 불변 클래스로 유지.

## 2. Flutter / Dart Rules
- **Formatting**: `flutter format` 및 `flutter analyze` 준수.
- **Widget Structure**: UI 재사용을 위해 작은 위젯 단위로 분리.
- **State Management**: `Riverpod Notifier` 패턴을 사용하며, UI는 `ref.watch`를 통해 반응형으로 연동.

## 3. Naming Conventions
- **Classes**: `PascalCase`
- **Variables / Methods**: `camelCase`
- **Files**: `snake_case`

## 4. Performance
- **Rebuild Optimization**: `const` 위젯 사용 및 `ref.select`를 통한 불필요한 리렌더링 방지.
- **Lazy Loading**: 대규모 데이터나 에셋은 필요 시점에 로드.
