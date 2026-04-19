# K-Poker - 화투 타짜 (Flutter 버전)

## 프로젝트 개요
한국 전통 화투 + 로그라이크 + Balatro 스타일 시너지 스코어링 카드 게임.
**배포 타겟: Google Play (Android)** — 웹 배포(CrazyGames/itch.io)는 2026-04-19에 종료하고 모바일 단일 플랫폼으로 전환.

## 기술 스택
| 구분 | 기술 |
|------|------|
| 프레임워크 | Flutter 3.5+ / Dart 3.5+ |
| 상태관리 | Riverpod 2.5.1 + Riverpod Generator |
| 데이터 모델 | Freezed (불변 모델) + JSON Serializable |
| 오디오 | audioplayers 6.0 |
| 저장소 | shared_preferences |
| 광고 | google_mobile_ads (AdMob) |
| 업데이트 | in_app_update (Google Play Core) |
| 타겟 | **Android (Google Play)** + Windows (개발용) |
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
  services/  # AdService, UpdateService 등 플랫폼 서비스
  common/    # 상수, 유틸리티
```

## 명령어
```powershell
flutter pub get                           # 의존성 설치
flutter run -d windows                    # Windows 개발 실행 (빠른 반복)
flutter run -d android --release          # Android 실기기 릴리스 테스트
flutter build appbundle --release         # Play Store용 AAB 빌드
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
- **Breaking Change 주의**: `lib/engine/` 또는 `lib/models/` 파일 수정 시, 기존 public 메서드/필드 삭제·이름 변경은 반드시 마스터 확인 후 진행

## Google Play 배포 파이프라인

### 통합 검증 (권장)
```bash
bash tool/android_full_check.sh .
```
4단계 자동 실행 — Pre-build 정적 검증 → analyze → build → Post-build 실물 검증 → `releases/` 복사.

### 개별 단계
1. `flutter analyze` → 0 issues
2. `bash tool/android_release_check.sh .` — 12개 갭 항목 정적 검증
3. `flutter build appbundle --release` — AAB 빌드
4. `bash tool/android_aab_verify.sh .` — 빌드된 AAB 실물 검증
5. Play Console 업로드

### 릴리스 빌드 필수 체크
- `android/app/src/main/AndroidManifest.xml`에 `<uses-permission android:name="android.permission.INTERNET"/>` 필수
- `android/app/build.gradle.kts`에 `isShrinkResources = false` (Flutter 에셋 오삭제 방지)
- `proguard-rules.pro`에 `audioplayers`, `google_mobile_ads`, `play.core` keep 규칙 유지
- `pubspec.yaml`의 `version: X.Y.Z+N` — 업로드 시도마다 `+N` 반드시 +1 (versionCode 영구 사용)

### AdMob
- `AndroidManifest.xml`의 `com.google.android.gms.ads.APPLICATION_ID` 실제 앱 ID 확인
- `app-ads.txt` 루트 도메인 배포 (h2techjun.github.io)

## 플랫폼 지원 정책
- **Android**: 프로덕션 타겟 ✅
- **Windows**: 개발·디버깅 편의용 유지 (빠른 hot reload)
- **Web**: 2026-04-19 비활성화 (`flutter config --no-enable-web`). 필요 시 `--enable-web`으로 복구 가능
- **iOS**: 계획 없음
