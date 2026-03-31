---
name: Flutter CanvasKit CDP Click
description: Flutter CanvasKit 웹에서 Playwright 클릭이 안 먹힐 때 CDP Input.dispatchMouseEvent로 해결하는 방법
type: feedback
---

Flutter CanvasKit(WebGL) 웹 빌드에서는 일반적인 DOM 클릭(`page.click()`, `element.dispatchEvent(new PointerEvent(...))`)이 Flutter 엔진까지 전달되지 않는다.

**해결법**: Chrome DevTools Protocol(CDP)의 `Input.dispatchMouseEvent`를 직접 사용하면 브라우저 레벨에서 마우스 이벤트를 주입하므로 shadowRoot 안의 Flutter canvas에도 정상 전달된다.

```javascript
const cdp = await context.newCDPSession(page);
await cdp.send('Input.dispatchMouseEvent', {
  type: 'mousePressed', x, y, button: 'left', clickCount: 1, pointerType: 'mouse',
});
await new Promise(r => setTimeout(r, 50));
await cdp.send('Input.dispatchMouseEvent', {
  type: 'mouseReleased', x, y, button: 'left', clickCount: 1, pointerType: 'mouse',
});
```

**Why:** Flutter 3.41+ CanvasKit은 `flutter-view` shadowRoot 안의 canvas에서 모든 이벤트를 처리한다. Playwright의 `page.mouse.click()`은 내부적으로 CDP를 사용하지만, 명시적 CDP 세션을 열어서 직접 `Input.dispatchMouseEvent`를 보내는 것이 더 확실하다.

**How to apply:** K-Poker QA 스크립트(`tool/qa_browser_test.mjs`)에서 이 방식을 사용 중. Flutter 웹 테스트 시 항상 CDP 방식 우선 사용.

추가 팁:
- `--web-renderer html` 옵션은 Flutter 3.41+에서 제거됨 (CanvasKit만 지원)
- 좌표 기반 클릭이므로 FittedBox 스케일링을 고려한 좌표 계산 필요
- 화면 변화 감지는 스크린샷 파일 크기 비교(500B 이상 차이)로 충분
