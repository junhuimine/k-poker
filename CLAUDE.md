# K-Poker - 화투 타짜 (Flutter 버전)

## 프로젝트 개요
한국 전통 화투 + 로그라이크 + Balatro 스타일 시너지 스코어링 카드 게임. Flutter 네이티브 버전.

## 기술 스택
| 구분 | 기술 |
|------|------|
| 프레임워크 | Flutter 3.5+ / Dart 3.5+ |
| 상태관리 | Riverpod 2.5.1 + Riverpod Generator |
| 데이터 모델 | Freezed (불변 모델) + JSON Serializable |
| 오디오 | audioplayers 6.0 |
| 저장소 | shared_preferences |
| 타겟 | Windows, Web (Chrome) |
| 아키텍처 | DDD (Domain-Driven Design) |

## 구조
```
lib/
  models/    # 데이터 모델 (CardDef, RoundState 등)
  data/      # 정적 데이터 (48장 카드, 조합, 스킬)
  engine/    # 순수 게임 로직 (UI 독립)
  state/     # Riverpod 상태 관리
  ui/        # Flutter 위젯 & 화면
  audio/     # 효과음 관리
  i18n/      # 국제화
  common/    # 상수, 유틸리티
```

## 명령어
```powershell
flutter pub get                           # 의존성 설치
flutter run -d windows                    # Windows 실행
flutter run -d chrome                     # Web 실행
flutter build web --release               # Web 프로덕션 빌드
flutter test                              # 유닛 테스트
dart run build_runner build --delete-conflicting-outputs  # Freezed/Riverpod 코드 생성
```

## 카드 스킨 시스템
- `assets/images/cards/` — 기본 화투 스킨 (전통 스타일)
- `assets/images/cards_manga_v2/` — 만화 스킨 (m01_bright, m01_junk_1 등)
- 카드 파일명 규칙: `{월}_{타입}.png` (기본) / `m{월}_{타입}.png` (만화)

## 규칙
- `.agent/` 디렉토리에 상세 문서 참조 (DOMAIN_KNOWLEDGE, CODEBASE_MAP, CODING_STANDARDS 등)
- `engine/`은 순수 로직만 — UI 의존성 절대 금지
- Freezed 모델 변경 시 `dart run build_runner build` 필수
- 웹 버전(07_hwatu-tazza)과 게임 규칙 동기화 유지
