/**
 * Find the exact coordinates of language chips in settings overlay.
 * Strategy: Open settings, then click at different x,y positions
 * and take screenshots after each click to see which chip gets selected.
 *
 * The settings overlay image shows language chips at these approximate visual positions
 * (as percentage of 1280x720):
 * - "한국어" chip: roughly centered at ~19.2%, 42.5% -> x=246, y=306 (in 1280x720)
 *
 * Wait -- looking at the screenshot again more carefully:
 * The overlay is 360px wide, centered in 1280px = left edge at (1280-360)/2 = 460
 * Padding = 24px on each side, so content area: x=484 to x=796
 *
 * But the screenshot shows the overlay content clearly.
 * Let me measure pixel positions from the screenshot image directly.
 *
 * The image resolution matches the viewport (1280x720) since deviceScaleFactor=1.
 *
 * From the settings screenshot, measuring approximate pixel positions of chip text:
 * - "한국어" text starts at roughly x=499, y=278, chip center ~(512, 285)
 * - "English" text at roughly x=548, y=278, chip center ~(570, 285)
 * - "日本語" text at roughly x=602, y=278, chip center ~(617, 285)
 * - "简体中文" second row, chip center ~(513, 322)
 * - "繁體中文" ~(575, 322)
 * - "Español" ~(637, 322)
 * - "Français" ~(513, 356)
 * - "Deutsch" ~(575, 356)
 * - "Português" ~(644, 356)
 * - "ภาษาไทย" ~(513, 390)
 *
 * But earlier tests showed clicking (580, 300) hit the SFX slider.
 * That means the chips are LOWER than y=300.
 *
 * Let me recalculate based on the overlay layout:
 * Overlay starts at y = (720 - overlay_height) / 2
 * The maxHeight is 85% of 720 = 612, but actual content may be shorter
 * The overlay has padding=24 on all sides
 *
 * Looking at the screenshot even more carefully, the settings panel occupies
 * roughly the center 360px horizontally and most of the vertical space.
 * The panel top edge is at approximately y=52 in the 1280x720 image.
 * Panel has padding = 24px.
 *
 * Content starts at y = 52 + 24 = 76
 * Header "설정" + X: ~30px high -> y = 106
 * Divider: y = 108
 * SizedBox(8): y = 116
 * BGM volume row (label + slider): ~60px -> y = 176
 * SizedBox(12): y = 188
 * SFX volume row: ~60px -> y = 248
 * SizedBox(16): y = 264
 * Divider: y = 266
 * SizedBox(12): y = 278
 * "언어" label: ~20px -> y = 298
 * SizedBox(8): y = 306
 * Language chips Wrap widget:
 *   Row 1 (3 chips): ~28px high -> y_center = 320
 *   Row 2 (3 chips + spacing 6): y_center = 354
 *   Row 3 (3 chips): y_center = 388
 *   Row 4 (1 chip): y_center = 422
 *
 * These are still estimates. Let me test y values from 305 to 430 with the
 * "English" x position to find the exact row.
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

  // Test clicking at various y positions with x=570 (should hit "English" column)
  // If the chip is there, the selection highlight should change
  console.log('=== Grid test: x=570, varying y from 305 to 440 ===');
  console.log('(Looking for English chip to get highlighted)\n');

  for (let y = 305; y <= 440; y += 5) {
    // Re-open settings if it got closed
    const before = await page.screenshot();

    await page.mouse.click(570, y);
    await page.waitForTimeout(400);

    const after = await page.screenshot();

    // Compare screenshots to detect change
    const changed = Buffer.compare(before, after) !== 0;

    if (changed) {
      await page.screenshot({ path: join(SCREENSHOT_DIR, `chip_y${y}.png`) });
      console.log(`[CHANGE] y=${y} - Something happened! Screenshot saved.`);
    } else {
      console.log(`         y=${y} - No change`);
    }
  }

  // Also test x axis at the y that showed change
  console.log('\n=== Also testing x axis at y=350 ===');
  // First reopen settings
  await page.mouse.click(200, 360);
  await page.waitForTimeout(500);
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1200);

  for (let x = 480; x <= 700; x += 10) {
    const before = await page.screenshot();
    await page.mouse.click(x, 350);
    await page.waitForTimeout(400);
    const after = await page.screenshot();
    const changed = Buffer.compare(before, after) !== 0;
    if (changed) {
      await page.screenshot({ path: join(SCREENSHOT_DIR, `chip_x${x}_y350.png`) });
      console.log(`[CHANGE] x=${x}, y=350 - Screenshot saved.`);
    } else {
      console.log(`         x=${x}, y=350 - No change`);
    }
  }

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
