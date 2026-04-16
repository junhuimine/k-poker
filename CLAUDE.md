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
- **Breaking Change 주의**: `lib/engine/` 또는 `lib/models/` 파일 수정 시, 기존 public 메서드/필드 삭제·이름 변경은 반드시 마스터 확인 후 진행

## CrazyGames 웹 배포
> **빌드만으로는 안 됨 — deploy_patch.py 필수!**

```powershell
# 1. 빌드 (환경변수 자동 주입)
powershell -File tool/build_web.ps1

# 2. 후처리 (필수! 안 하면 검은 화면)
python tool/deploy_patch.py

# 3. build/web 폴더를 CrazyGames Developer Portal에 업로드
```

### deploy_patch.py 역할
1. `<base href>` → `"./"` (CDN 호환 상대경로)
2. AssetManifest / FontManifest 인라인 임베딩 (CDN 403 우회)
3. 서비스워커 제거 (CrazyGames SW와 충돌 방지)
4. canvaskit/ 로컬 삭제 → CDN 자동 로드 (~24-32MB 절감)
5. .js.symbols 디버그 파일 제거

### SDK 연동 파일
```
web/index.html                              ← <script src="sdk.crazygames.com/crazygames-sdk-v3.js">
lib/services/crazygames.dart               ← 조건부 export (웹/비웹)
lib/services/crazygames_service.dart       ← dart:js_interop 실제 구현
lib/services/crazygames_service_stub.dart  ← 비웹 no-op
```

### SDK 라이프사이클
| 시점 | 호출 |
|------|------|
| main() | `loadingStart()` → `init()` |
| 게임 화면 로드 완료 | `loadingStop()` → `gameplayStart()` |
| 스테이지 종료 | `gameplayStop()` → `requestMidgameAd()` |
| 광고 종료 | `gameplayStart()` (재개) |
| 승리/달성 | `happytime()` |

### 플랫폼별 광고
| 플랫폼 | 광고 | 비고 |
|--------|------|------|
| CrazyGames | 자체 SDK (midgame/rewarded) | AdMob 불필요 |
| Google Play | AdMob (google_mobile_ads) | 별도 연동 필요 |
| itch.io | 없음 | 자체 수익 모델 |
