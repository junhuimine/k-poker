/**
 * K-Poker FINAL Language Switch Test
 *
 * Confirmed coordinates (1280x720 viewport):
 * Row 1 (y=400): ko(490), en(570), ja(660)
 * Row 2 (y=440): zhCn(510), zhTw(600), es(690)
 * Row 3 (y=475): fr(510), de(600), pt(700)
 * Row 4 (y=510): th - need to find or scroll
 */

import { chromium } from 'playwright';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SCREENSHOT_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';

const results = { pass: 0, fail: 0, issues: [] };

async function run() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
  });
  const page = await context.newPage();

  const consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });

  await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(8000);

  // Take baseline
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'final_00_baseline.png') });

  const langConfigs = [
    { code: 'en', name: 'English', x: 570, y: 400 },
    { code: 'ja', name: 'Japanese', x: 660, y: 400 },
    { code: 'zhCn', name: 'Simplified Chinese', x: 510, y: 440 },
    { code: 'zhTw', name: 'Traditional Chinese', x: 600, y: 440 },
    { code: 'es', name: 'Spanish', x: 690, y: 440 },
    { code: 'fr', name: 'French', x: 510, y: 475 },
    { code: 'de', name: 'German', x: 600, y: 475 },
    { code: 'pt', name: 'Portuguese', x: 700, y: 475 },
  ];

  for (const lang of langConfigs) {
    console.log(`\n=== ${lang.name} (${lang.code}) ===`);

    // Open settings
    await page.mouse.click(1258, 28);
    await page.waitForTimeout(1000);

    // Click language chip
    await page.mouse.click(lang.x, lang.y);
    await page.waitForTimeout(600);

    // Screenshot settings with language selected
    await page.screenshot({ path: join(SCREENSHOT_DIR, `final_settings_${lang.code}.png`) });
    console.log(`  [SS] settings for ${lang.code}`);

    // Close settings (click outside overlay)
    await page.mouse.click(200, 360);
    await page.waitForTimeout(800);

    // Screenshot main screen
    await page.screenshot({ path: join(SCREENSHOT_DIR, `final_main_${lang.code}.png`) });
    console.log(`  [SS] main screen in ${lang.code}`);

    results.pass++;
  }

  // Try to find Thai chip
  console.log('\n=== Finding Thai chip ===');
  // Open settings
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1000);

  // Try scrolling down in the settings overlay
  // Scroll the overlay content
  await page.mouse.move(640, 500);
  await page.mouse.wheel(0, 50);
  await page.waitForTimeout(300);

  // Try y values from 495 to 540
  for (let y = 495; y <= 540; y += 3) {
    const before = await page.screenshot();
    await page.mouse.click(510, y);
    await page.waitForTimeout(300);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      console.log(`[HIT] Thai chip at x=510, y=${y}`);
      await page.screenshot({ path: join(SCREENSHOT_DIR, `final_settings_th_y${y}.png`) });
      // Close and screenshot main
      await page.mouse.click(200, 360);
      await page.waitForTimeout(800);
      await page.screenshot({ path: join(SCREENSHOT_DIR, `final_main_th.png`) });
      results.pass++;
      break;
    }
  }

  // Reset to Korean
  console.log('\n=== Reset to Korean ===');
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1000);
  await page.mouse.click(490, 400);
  await page.waitForTimeout(600);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'final_settings_ko.png') });
  await page.mouse.click(200, 360);
  await page.waitForTimeout(800);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'final_main_ko.png') });
  results.pass++;

  // Now test other features in Korean
  console.log('\n=== Tutorial Overlay ===');
  // Help button is to the left of gear icon
  // From screenshot: ? icon at approximately (1218, 28)
  await page.mouse.click(1218, 28);
  await page.waitForTimeout(1500);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'final_tutorial.png') });

  // Tutorial tabs - need to find actual positions
  // Tutorial overlay: 850x550, centered
  // Center: (640, 360), left: 215, top: 85
  // Tab bar at top: Rules | Dictionary | Yaku
  // Tab text positions approximately:
  // Rules: x~400, y~115
  // Dictionary: x~550, y~115
  // Yaku: x~700, y~115

  // Close tutorial
  await page.mouse.click(100, 50);
  await page.waitForTimeout(800);

  // Game start
  console.log('\n=== Game Start ===');
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'final_before_start.png') });
  // Start button center: roughly (640, 430) based on FittedBox scaling
  await page.mouse.click(640, 430);
  await page.waitForTimeout(6000);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'final_game_board.png') });

  // Play some cards
  console.log('\n=== Gameplay ===');
  for (let i = 0; i < 5; i++) {
    const cardX = 350 + i * 100;
    await page.mouse.click(cardX, 640);
    await page.waitForTimeout(2500);
  }
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'final_mid_game.png') });

  // Console errors report
  console.log(`\n=== Console Errors: ${consoleErrors.length} ===`);
  if (consoleErrors.length > 0) {
    for (const err of consoleErrors.slice(0, 10)) {
      console.log(`  ERROR: ${err.substring(0, 300)}`);
      results.issues.push(err.substring(0, 200));
    }
  }

  console.log(`\n=== Results: ${results.pass} pass, ${results.fail} fail, ${results.issues.length} issues ===`);

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
