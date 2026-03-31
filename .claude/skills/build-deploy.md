---
name: build-deploy
description: K-Poker 빌드 및 배포. Flutter 웹 빌드, GitHub Pages/itch.io 배포 프로세스.
paths:
  - "pubspec.yaml"
  - "web/**/*"
  - "tool/**/*"
---

K-Poker 빌드 및 배포를 수행합니다.

## 현재 상태
- Git 상태: !`git status --short | head -5`
- 브랜치: !`git branch --show-current`
- 최근 커밋: !`git log --oneline -3`

## 빌드 명령어
```powershell
flutter build web --release --base-href /k-poker/    # GitHub Pages용
flutter build web --release                            # itch.io용
```

## 배포 대상
1. **GitHub Pages**: `--base-href /k-poker/` 필수, PowerShell로 실행
2. **itch.io**: Python zipfile로 ZIP 생성, 매니페스트 인라인, .ogg 변환, 서비스워커 제거

## 주의사항
- 웹 빌드 시 `web/index.html`의 base href 확인
- 오디오 파일은 .ogg 포맷 사용 (웹 호환성)
- `tool/deploy_patch.py`, `tool/deploy_zip.py` 참조
