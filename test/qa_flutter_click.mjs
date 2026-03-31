/**
 * Test Flutter web click event delivery
 * Flutter 3.x+ uses flutter-view element with shadow DOM for event handling
 */

import { chromium } from 'playwright';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SCREENSHOT_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';

async function run() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
  });
  const page = await context.newPage();
  await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(8000);

  // Inspect flutter-view shadow DOM
  const flutterViewInfo = await page.evaluate(() => {
    const fv = document.querySelector('flutter-view');
    if (!fv) return { found: false };
    const rect = fv.getBoundingClientRect();
    const shadow = fv.shadowRoot;
    let shadowInfo = [];
    if (shadow) {
      const walkShadow = (node, depth) => {
        if (depth > 3) return;
        for (const child of node.children || []) {
          const cr = child.getBoundingClientRect();
          shadowInfo.push({
            tag: child.tagName.toLowerCase(),
            id: child.id,
            w: Math.round(cr.width),
            h: Math.round(cr.height),
            x: Math.round(cr.x),
            y: Math.round(cr.y),
            style: child.style?.cssText?.substring(0, 300) || '',
            children: child.children.length,
            depth,
          });
          walkShadow(child, depth + 1);
        }
      };
      walkShadow(shadow, 0);
    }
    return {
      found: true,
      rect: { x: rect.x, y: rect.y, w: rect.width, h: rect.height },
      hasShadow: !!shadow,
      shadowElements: shadowInfo,
    };
  });

  console.log('=== flutter-view info ===');
  console.log(JSON.stringify(flutterViewInfo, null, 2));

  // Try dispatching events directly on flutter-view
  console.log('\n=== Testing direct event dispatch ===');

  // First, take baseline screenshot
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'click_test_00.png') });
  console.log('[SS] click_test_00.png (baseline)');

  // Method 1: Standard Playwright click
  console.log('\nMethod 1: Standard page.mouse.click on gear icon area (1258, 28)');
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1200);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'click_test_01_standard.png') });
  console.log('[SS] click_test_01_standard.png');

  // Method 2: Use page.dispatchEvent or evaluate to send pointer events
  // First close settings if it opened
  await page.mouse.click(200, 360);
  await page.waitForTimeout(800);

  console.log('\nMethod 2: Dispatch pointer events directly to flutter-view');
  await page.evaluate(({x, y}) => {
    const fv = document.querySelector('flutter-view');
    if (!fv) return;
    // Flutter uses pointer events, not mouse events
    const opts = {
      bubbles: true,
      cancelable: true,
      clientX: x,
      clientY: y,
      pointerId: 1,
      pointerType: 'mouse',
      isPrimary: true,
    };
    fv.dispatchEvent(new PointerEvent('pointerdown', opts));
    fv.dispatchEvent(new PointerEvent('pointerup', opts));
  }, {x: 1258, y: 28});
  await page.waitForTimeout(1200);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'click_test_02_pointer.png') });
  console.log('[SS] click_test_02_pointer.png');

  // Close again
  await page.evaluate(({x, y}) => {
    const fv = document.querySelector('flutter-view');
    if (!fv) return;
    const opts = { bubbles: true, cancelable: true, clientX: x, clientY: y, pointerId: 1, pointerType: 'mouse', isPrimary: true };
    fv.dispatchEvent(new PointerEvent('pointerdown', opts));
    fv.dispatchEvent(new PointerEvent('pointerup', opts));
  }, {x: 200, y: 360});
  await page.waitForTimeout(800);

  console.log('\nMethod 3: Use page.locator on flutter-view then click relative');
  const flutterView = page.locator('flutter-view');
  await flutterView.click({ position: { x: 1258, y: 28 } });
  await page.waitForTimeout(1200);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'click_test_03_locator.png') });
  console.log('[SS] click_test_03_locator.png');

  // Check if the locator approach worked (settings should be open)
  // Now try to click English language chip
  // First find the actual position by examining the screenshot more carefully

  // Close settings
  await flutterView.click({ position: { x: 200, y: 360 } });
  await page.waitForTimeout(800);

  // Method 4: Use touchscreen API (Flutter might respond better to touch)
  console.log('\nMethod 4: Touch events on gear icon');
  await page.touchscreen.tap(1258, 28);
  await page.waitForTimeout(1200);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'click_test_04_touch.png') });
  console.log('[SS] click_test_04_touch.png');

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
