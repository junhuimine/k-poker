# 🎴 K-Poker: 화투 로그라이크 카드 배틀

> 한국 전통 화투 + 로그라이크 요소를 결합한 모바일 카드 게임

## 세팅

### 사전 요구사항
- Flutter SDK 3.5+
- Dart 3.5+

### 프로젝트 초기화

```bash
# 1. Flutter 프로젝트 생성
cd D:\02_PROJECT\08_k-poker
flutter create --org com.kpoker --project-name k_poker .

# 2. 종속성 설치
flutter pub get

# 3. 실행
flutter run -d windows
# 또는
flutter run -d chrome --web-port=8080
```

### 에셋
- 카드 이미지: `assets/images/cards/` (48장 + 카드 뒷면 포함)
- 오디오: `assets/audio/`
- 폰트: `assets/fonts/` (Pretendard)

## 아키텍처

```
lib/
├── models/       → 데이터 모델 (CardDef, RoundState 등)
├── data/         → 정적 데이터 (48장 카드, 족보, 스킬)
├── engine/       → 순수 게임 로직 (UI 의존 없음)
├── state/        → Riverpod 상태 관리
├── ui/           → Flutter 위젯 (화면, 카드, 필드)
├── audio/        → 효과음 관리
└── common/       → 상수, 유틸리티
```

## 프로젝트 이력

원래 `D:\02_PROJECT\07_hwatu-tazza` (React/TypeScript)에서 시작하여 Flutter로 전환한 독립 프로젝트입니다.
게임 로직(매칭, 점수, 고스톱)은 1:1 포팅되었으며, UI만 Flutter로 새로 설계했습니다.
