/**
 * Verify language chip coordinates in the new build
 */

import { chromium } from 'playwright';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SS_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';

async function run() {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 });
  const page = await ctx.newPage();
  await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(8000);

  // Open settings
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1200);
  await page.screenshot({ path: join(SS_DIR, 'verify_settings_open.png') });

  // Scan for English chip (try x=570, y from 380 to 420)
  console.log('=== Scanning for English chip ===');
  for (let y = 370; y <= 430; y += 2) {
    const before = await page.screenshot();
    await page.mouse.click(570, y);
    await page.waitForTimeout(200);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      console.log(`[HIT] y=${y}`);
      await page.screenshot({ path: join(SS_DIR, `verify_en_y${y}.png`) });
    }
  }

  // Also try the wider scan
  console.log('\n=== Wide Y scan x=570, y=300-550 ===');
  // Reopen settings fresh
  await page.mouse.click(200, 360);
  await page.waitForTimeout(500);
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1200);

  for (let y = 300; y <= 550; y += 5) {
    const before = await page.screenshot();
    await page.mouse.click(570, y);
    await page.waitForTimeout(200);
    const after = await page.screenshot();
    if (Buffer.compare(before, after) !== 0) {
      console.log(`[HIT] y=${y}`);
    }
  }

  await ctx.close();
  await browser.close();
}

run().catch(e => console.error('[FATAL]', e));
