/**
 * Coordinate finder: Take a high-res screenshot of settings overlay
 * and draw a grid to help map coordinates precisely.
 *
 * Also tests clicking at specific positions by taking before/after screenshots.
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

  // Open settings
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1200);

  // Get the actual pixel dimensions of the screenshot
  const screenshot1 = await page.screenshot();
  console.log(`Screenshot buffer size: ${screenshot1.length} bytes`);

  // Save settings screenshot at full resolution
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'coord_settings_full.png') });
  console.log('[SS] coord_settings_full.png');

  // Now let's systematically test clicking different positions
  // to find where the language chips actually are.
  // Method: click a position, take a screenshot, check if selection changed.

  // Check if Flutter has a semantics overlay
  const semanticsEnabled = await page.evaluate(() => {
    // Check for Flutter semantics elements
    const sems = document.querySelectorAll('flt-semantics, flt-semantics-placeholder, [role]');
    return {
      count: sems.length,
      roles: [...new Set([...sems].map(s => s.getAttribute('role')).filter(Boolean))],
      ariaLabels: [...sems].map(s => ({
        tag: s.tagName,
        role: s.getAttribute('role'),
        label: s.getAttribute('aria-label'),
        rect: s.getBoundingClientRect ? {
          x: Math.round(s.getBoundingClientRect().x),
          y: Math.round(s.getBoundingClientRect().y),
          w: Math.round(s.getBoundingClientRect().width),
          h: Math.round(s.getBoundingClientRect().height),
        } : null,
      })).filter(s => s.label || s.role).slice(0, 50),
    };
  });
  console.log('\n--- Flutter Semantics Elements ---');
  console.log(JSON.stringify(semanticsEnabled, null, 2));

  // Try a systematic grid click test on the settings overlay
  // Click at different Y positions in the language chip area (x=520 center of first column)
  console.log('\n--- Grid Click Test (language area) ---');

  // Save initial state
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'coord_test_initial.png') });

  // The settings overlay is approximately at center (640, 360) with width 360
  // Try clicking different y values from 250 to 420 with x=580 (should hit "English")
  for (let y = 260; y <= 410; y += 10) {
    // Click the position
    await page.mouse.click(580, y);
    await page.waitForTimeout(300);
    await page.screenshot({ path: join(SCREENSHOT_DIR, `coord_y${y}.png`) });
    console.log(`Clicked (580, ${y})`);
  }

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
