/**
 * Test with service worker disabled to bypass cache
 */

import { chromium } from 'playwright';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SS_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';

async function run() {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
    serviceWorkers: 'block', // Block service workers to bypass cache
  });
  const page = await ctx.newPage();

  // Also disable cache
  await page.route('**/*', route => {
    route.continue({ headers: {
      ...route.request().headers(),
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
    }});
  });

  const consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error' || msg.text().includes('EXCEPTION')) {
      consoleErrors.push(msg.text());
    }
  });

  await page.goto(BASE_URL + '?v=' + Date.now(), { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(10000);
  await page.screenshot({ path: join(SS_DIR, 'nc_01_start.png') });
  console.log('[SS] Start screen');

  // Open settings
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1200);
  await page.screenshot({ path: join(SS_DIR, 'nc_02_settings.png') });
  console.log('[SS] Settings');

  // Click English
  await page.mouse.click(570, 400);
  await page.waitForTimeout(1000);
  await page.screenshot({ path: join(SS_DIR, 'nc_03_after_en.png') });
  console.log('[SS] After English click');

  // Close
  await page.mouse.click(200, 360);
  await page.waitForTimeout(800);
  await page.screenshot({ path: join(SS_DIR, 'nc_04_main_en.png') });
  console.log('[SS] Main screen (should be English)');

  // Console errors
  console.log(`\nConsole errors: ${consoleErrors.length}`);
  for (const e of consoleErrors.slice(0, 5)) {
    console.log(`  - ${e.substring(0, 300)}`);
  }

  await ctx.close();
  await browser.close();
}

run().catch(e => console.error('[FATAL]', e));
