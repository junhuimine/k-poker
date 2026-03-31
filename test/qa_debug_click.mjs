/**
 * Debug: Open settings fresh, immediately screenshot,
 * then click English chip at (570, 400), screenshot again.
 * Compare to see if change happened.
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

  // Step 1: Open settings fresh
  console.log('Step 1: Click gear icon at (1258, 28)');
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1500);
  const ss1 = await page.screenshot();
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'dbg_step1_settings_open.png') });
  console.log('  Settings opened');

  // Step 2: Click English chip at confirmed (570, 400)
  console.log('Step 2: Click English at (570, 400)');
  await page.mouse.click(570, 400);
  await page.waitForTimeout(800);
  const ss2 = await page.screenshot();
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'dbg_step2_after_en_click.png') });
  const changed1 = Buffer.compare(ss1, ss2) !== 0;
  console.log(`  Changed: ${changed1}`);

  // Step 3: If no change, try other y values near 400
  if (!changed1) {
    for (let y = 380; y <= 420; y += 2) {
      const before = await page.screenshot();
      await page.mouse.click(570, y);
      await page.waitForTimeout(300);
      const after = await page.screenshot();
      if (Buffer.compare(before, after) !== 0) {
        console.log(`  [FOUND] English chip at y=${y}`);
        await page.screenshot({ path: join(SCREENSHOT_DIR, `dbg_en_y${y}.png`) });
        break;
      }
    }
  }

  // Step 4: Close settings and reopen to test from clean state
  console.log('\nStep 4: Close & reopen');
  await page.mouse.click(200, 360);
  await page.waitForTimeout(800);

  // Open again
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1500);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'dbg_step4_reopened.png') });

  // Now scan y=370 to 420 at x=570
  console.log('Step 5: Scan y=370-420 at x=570');
  for (let y = 370; y <= 420; y += 2) {
    const before = await page.screenshot();
    await page.mouse.click(570, y);
    await page.waitForTimeout(300);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      console.log(`  [FOUND after reopen] y=${y}`);
      await page.screenshot({ path: join(SCREENSHOT_DIR, `dbg_reopen_y${y}.png`) });
    }
  }

  // Also check: maybe the settings panel scrolled between opens
  // Try wider scan
  console.log('\nStep 6: Wide scan y=300-550 at x=570');
  // Close and reopen fresh
  await page.mouse.click(200, 360);
  await page.waitForTimeout(500);
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1500);

  for (let y = 300; y <= 550; y += 5) {
    const before = await page.screenshot();
    await page.mouse.click(570, y);
    await page.waitForTimeout(200);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      console.log(`  [HIT] y=${y}`);
    }
  }

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
