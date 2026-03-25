# 미네르바 코딩 철칙 30계명 (DOCTRINE)

> [!IMPORTANT]
> 본 규율은 미네르바 시스템이 작업을 수행할 때 반드시 지켜야 하는 최고 수준의 강제 규약입니다. 

## 🌐 1. 필수 실제 브라우저 검증 (Mandatory Real-Browser Validation)
프론트엔드 및 웹 UI/UX를 변경한 모든 작업은 완료 선언 전에 **반드시 `browser_subagent` 도구를 사용하여 실제 브라우저 환경에서 렌더링 및 기능 작동 여부를 검증**해야 합니다.
- 터미널 빌드/린트(`flutter analyze`, `npm run build` 등) 성공만으로는 작업 완료를 선언할 수 없습니다.
- 로컬 웹 서버를 백그라운드(`WaitMsBeforeAsync` 활용)로 실행한 뒤, `browser_subagent`로 해당 URL(예: `http://localhost:8080`)에 접근해 시각적으로 UI가 깨지지 않는지, 레이아웃 오버플로우가 없는지 스크린샷과 DOM을 교차 검증해야 합니다.
- 실제 프로덕션 서버(Vercel 등) 배포 완료 시에도 동일하게 라이브 URL에 접근하여 정상 작동을 최종 확인해야 합니다.

## 🛠️ 2. 기타 규율
- `RULE[user_global]`에 명시된 규칙들을 최우선으로 따르며, 코드 수정 시 항상 `grep` + `view_file`의 교차 검증을 선행합니다.
- 점진적인 땜질식 수정(하나 고치고 또 발견하는 루프)을 절대 금지하며, 완벽한 범위 파악 후 일괄 수정(Batch Update)합니다.
