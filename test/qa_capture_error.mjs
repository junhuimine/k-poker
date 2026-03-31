/**
 * Capture the error screen with higher detail.
 * Also capture console output for the error.
 */

import { chromium } from 'playwright';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SCREENSHOT_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';

async function run() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 },
    deviceScaleFactor: 1,
  });
  const page = await context.newPage();

  const consoleMessages = [];
  page.on('console', msg => {
    consoleMessages.push({ type: msg.type(), text: msg.text() });
  });
  page.on('pageerror', err => {
    consoleMessages.push({ type: 'PAGE_ERROR', text: err.message });
  });

  await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(8000);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'err_01_start.png') });

  // Open settings (gear icon - top right at 1920x1080)
  // Gear icon: top-right area. Positions scale with FittedBox
  // At 1920x1080, the game overlay uses FittedBox with 1200x700
  // So the scale factor is min(1920/1200, 1080/700) = min(1.6, 1.54) = 1.54
  // Positioned(top:16, right:16) ->
  //   actual right = 16*1.54 + offset, actual top = 16*1.54 + offset
  // Actually FittedBox centers the content
  // Width: 1200 * 1.54 = 1848, offset_x = (1920-1848)/2 = 36
  // Height: 700 * 1.54 = 1078, offset_y = (1080-1078)/2 = 1
  // Gear at top-right: x = 1920 - 36 - 16*1.54 = ~1859, y = 1 + 16*1.54 = ~26

  // But the settings/help icons are in a Positioned(top:16, right:16) INSIDE the Stack
  // which is the full FittedBox area. So they scale with the FittedBox.
  // At 1920x1080: gear icon approximately at (1882, 26)
  // Actually let me just use proportional coords from 1280x720:
  // gear was at ~(1258, 28) in 1280x720
  // Proportional: (1258/1280*1920, 28/720*1080) = (1887, 42)
  await page.mouse.click(1887, 42);
  await page.waitForTimeout(1500);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'err_02_settings.png') });

  // Click English chip - proportional from 1280x720:
  // (570/1280*1920, 400/720*1080) = (855, 600)
  await page.mouse.click(855, 600);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'err_03_after_en.png') });

  // Wait and capture error details
  await page.waitForTimeout(2000);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'err_04_final.png') });

  // Print all console messages
  console.log('=== Console Messages ===');
  for (const msg of consoleMessages) {
    console.log(`[${msg.type}] ${msg.text.substring(0, 500)}`);
  }

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
