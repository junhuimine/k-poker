---
name: build-deploy
description: K-Poker Google Play 빌드 및 배포. Android AAB 빌드, 전수 검증, Play Console 업로드 프로세스.
paths:
  - "pubspec.yaml"
  - "android/**/*"
  - "tool/android_*.sh"
---

K-Poker Google Play 빌드 및 배포를 수행합니다.

## 현재 상태
- Git 상태: !`git status --short | head -5`
- 브랜치: !`git branch --show-current`
- 최근 커밋: !`git log --oneline -3`
- 현재 버전: !`grep "^version:" pubspec.yaml`

## 빌드 명령어
```bash
# 권장: 통합 파이프라인 (정적 검증 + 빌드 + 실물 검증 + releases/ 복사)
bash tool/android_full_check.sh .

# 개별 수동 실행
flutter analyze                             # 0 issues 필수
bash tool/android_release_check.sh .        # Pre-build 12개 갭 검증
flutter build appbundle --release           # AAB 빌드
bash tool/android_aab_verify.sh .           # Post-build 실물 검증
```

## 업로드 순서
1. `releases/k-poker-v{version}.aab` 확인
2. Play Console → 프로덕션/내부테스트 → 새 버전 만들기
3. AAB 업로드 → 출시 노트 → 롤아웃

## 주의사항 (Play Store 거절 #1~3 사유)
- **INTERNET 퍼미션**: 디버그는 자동, 릴리스는 수동 (AndroidManifest.xml 확인)
- **isShrinkResources = false**: R8이 Flutter 에셋 삭제해서 흰 화면/오디오 끊김 발생
- **versionCode 영구 사용**: 업로드 시도 = 영구 소모, 거절 시 `pubspec.yaml +N` +1
- **AdMob APPLICATION_ID**: 테스트 ID로 두면 수익 0원

## 롤백
Play Console에서 이전 AAB로 롤백 (같은 versionCode 재사용 불가 — `pubspec +N` 올려서 재빌드).
