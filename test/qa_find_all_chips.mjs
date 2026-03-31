/**
 * Find ALL language chip coordinates.
 * From previous test: x=570, y=400 = English, x=570, y=440 = 简体中文
 *
 * Language chip rows (each ~28px high, spacing 6px):
 * Row 1 (한국어, English, 日本語): y ~ 395-405
 * Row 2 (简体中文, 繁體中文, Español): y ~ 430-445
 * Row 3 (Français, Deutsch, Português): y ~ 465-475
 * Row 4 (ภาษาไทย): y ~ 500-510
 *
 * X positions: overlay content width = 360 - 48 = 312
 * Chips have spacing=6, each chip roughly 70-90px wide
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

  // Collect console errors
  const consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });

  await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(8000);

  // Open settings
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1200);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'chips_initial.png') });

  // Test: Click English at (570, 400) - confirmed from previous test
  console.log('=== Testing English at (570, 400) ===');
  await page.mouse.click(570, 400);
  await page.waitForTimeout(600);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'chips_en_570_400.png') });

  // Now check header text in the screenshot to verify language changed
  // If "Settings" is shown instead of "설정", English is active

  // Reset to Korean - need to find Korean chip
  // Korean should be the first chip, x ~ 495-520, same y row
  console.log('\n=== Finding Korean chip (Row 1, first chip) ===');
  for (let x = 480; x <= 550; x += 5) {
    const before = await page.screenshot();
    await page.mouse.click(x, 400);
    await page.waitForTimeout(300);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      await page.screenshot({ path: join(SCREENSHOT_DIR, `chips_ko_x${x}.png`) });
      console.log(`[HIT] x=${x}, y=400 -> changed!`);
    }
  }

  // Now systematically test each row to find all chips
  // First reset to known state (Korean)
  await page.mouse.click(495, 400);
  await page.waitForTimeout(500);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'chips_reset_ko.png') });

  // Test Row 1 (y=400): find all 3 chips (Korean, English, Japanese)
  console.log('\n=== Row 1 y=400: Scanning x=480 to 700 ===');
  for (let x = 480; x <= 700; x += 5) {
    const before = await page.screenshot();
    await page.mouse.click(x, 400);
    await page.waitForTimeout(300);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      await page.screenshot({ path: join(SCREENSHOT_DIR, `row1_x${x}.png`) });
      console.log(`[HIT] x=${x}, y=400`);
    }
  }

  // Reset to Korean
  await page.mouse.click(495, 400);
  await page.waitForTimeout(500);

  // Test Row 2 (y=440): find all 3 chips (zhCn, zhTw, es)
  console.log('\n=== Row 2 y=440: Scanning x=480 to 700 ===');
  for (let x = 480; x <= 700; x += 5) {
    const before = await page.screenshot();
    await page.mouse.click(x, 440);
    await page.waitForTimeout(300);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      await page.screenshot({ path: join(SCREENSHOT_DIR, `row2_x${x}.png`) });
      console.log(`[HIT] x=${x}, y=440`);
      // Reset to Korean
      await page.mouse.click(495, 400);
      await page.waitForTimeout(300);
    }
  }

  // Test Row 3 (y=475): find Français, Deutsch, Português
  console.log('\n=== Row 3 y=475: Scanning x=480 to 720 ===');
  for (let x = 480; x <= 720; x += 5) {
    const before = await page.screenshot();
    await page.mouse.click(x, 475);
    await page.waitForTimeout(300);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      await page.screenshot({ path: join(SCREENSHOT_DIR, `row3_x${x}.png`) });
      console.log(`[HIT] x=${x}, y=475`);
      // Reset to Korean
      await page.mouse.click(495, 400);
      await page.waitForTimeout(300);
    }
  }

  // Test Row 4 (y=510): ภาษาไทย
  console.log('\n=== Row 4 y=510: Scanning x=480 to 600 ===');
  for (let x = 480; x <= 600; x += 5) {
    const before = await page.screenshot();
    await page.mouse.click(x, 510);
    await page.waitForTimeout(300);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      await page.screenshot({ path: join(SCREENSHOT_DIR, `row4_x${x}.png`) });
      console.log(`[HIT] x=${x}, y=510`);
      // Reset to Korean
      await page.mouse.click(495, 400);
      await page.waitForTimeout(300);
    }
  }

  // Report console errors
  if (consoleErrors.length > 0) {
    console.log(`\n=== Console Errors: ${consoleErrors.length} ===`);
    for (const err of consoleErrors.slice(0, 5)) {
      console.log(`  - ${err.substring(0, 200)}`);
    }
  }

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
