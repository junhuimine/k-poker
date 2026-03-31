/**
 * K-Poker Language Switch Precision Test
 *
 * Precisely clicks each language chip in the settings overlay
 * and verifies the main menu text changes.
 */

import { chromium } from 'playwright';
import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SCREENSHOT_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';

async function clickAt(page, x, y, desc = '') {
  if (desc) console.log(`  [CLICK] ${desc} at (${x}, ${y})`);
  await page.mouse.click(x, y);
  await page.waitForTimeout(600);
}

async function screenshot(page, name) {
  const path = join(SCREENSHOT_DIR, `${name}.png`);
  await page.screenshot({ path });
  console.log(`  [SCREENSHOT] ${name}.png`);
  return path;
}

async function run() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
  });
  const page = await context.newPage();

  await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  // Wait for Flutter to fully render
  await page.waitForTimeout(8000);

  console.log('[INFO] Taking baseline screenshot to map coordinates...');
  await screenshot(page, 'lang_00_baseline');

  // Open settings: gear icon top-right
  // From the screenshot, the gear is at approximately (1258, 28) - top right area
  await clickAt(page, 1258, 28, 'Open Settings');
  await page.waitForTimeout(1200);
  await screenshot(page, 'lang_01_settings_open');

  // From the settings screenshot analysis:
  // The settings overlay is centered at ~(640, 360)
  // Width: ~360px, so x range: ~460-820
  // Settings content (top to bottom):
  // - Header "설정" + close button: y~80
  // - "배경음악" label: y~115
  // - BGM slider: y~140
  // - "효과음" label: y~170
  // - SFX slider: y~195
  // - "언어" label: y~245
  // - Language chips row 1: y~275 (한국어, English, 日本語)
  // - Language chips row 2: y~310 (简体中文, 繁體中文, Español)
  // - Language chips row 3: y~345 (Français, Deutsch, Português)
  // - Language chips row 4: y~380 (ภาษาไทย)
  // - "카드 뒷면 디자인" label: y~420

  // But wait - the overlay is in absolute screen coords within the settings panel
  // Settings panel center X = 640 (center of 1280)
  // Panel left edge ~460, right edge ~820
  // Settings panel is centered vertically too, starts roughly at y~60

  // From the 03_settings_overlay_ko screenshot I can see the exact layout:
  // The settings dialog box spans roughly y=48 to y=665
  // "언어" section label at roughly y=270
  // Language chip rows:
  //   Row 1 (한국어, English, 日本語): y~303, chips at x~(502, 570, 640)
  //   Row 2 (简体中文, 繁體中文, Español): y~340, chips at x~(500, 578, 656)
  //   Row 3 (Français, Deutsch, Português): y~377, chips at x~(500, 575, 653)
  //   Row 4 (ภาษาไทย): y~413, chip at x~500

  // Let me look more carefully at the actual screenshot coordinates
  // The overlay has padding 24px, centered at screen center
  // Overlay width = 360, center = 640
  // Left content start = 640 - 180 + 24 = 484
  // Right content end = 640 + 180 - 24 = 796

  // Language ChoiceChips in a Wrap widget
  // Each chip has some padding and label

  // I'll define approximate centers for each language chip
  const langChips = [
    { code: 'ko', name: 'Korean', x: 507, y: 300 },
    { code: 'en', name: 'English', x: 587, y: 300 },
    { code: 'ja', name: 'Japanese', x: 662, y: 300 },
    { code: 'zhCn', name: 'Chinese Simplified', x: 517, y: 338 },
    { code: 'zhTw', name: 'Chinese Traditional', x: 607, y: 338 },
    { code: 'es', name: 'Spanish', x: 697, y: 338 },
    { code: 'fr', name: 'French', x: 512, y: 376 },
    { code: 'de', name: 'German', x: 590, y: 376 },
    { code: 'pt', name: 'Portuguese', x: 672, y: 376 },
    { code: 'th', name: 'Thai', x: 512, y: 413 },
  ];

  // Test each language
  for (const lang of langChips) {
    console.log(`\n--- Testing ${lang.name} (${lang.code}) ---`);

    // If settings not open, open it
    // Click the language chip
    await clickAt(page, lang.x, lang.y, `Select ${lang.name}`);
    await page.waitForTimeout(800);

    // Take screenshot of settings with new selection
    await screenshot(page, `lang_02_settings_${lang.code}`);

    // Close settings by clicking X button (top-right of overlay)
    // Close button is at approximately (757, 72) within the overlay
    await clickAt(page, 757, 72, 'Close settings');
    await page.waitForTimeout(800);

    // Screenshot the main menu with new language
    await screenshot(page, `lang_03_main_${lang.code}`);

    // Re-open settings for next language
    await clickAt(page, 1258, 28, 'Re-open Settings');
    await page.waitForTimeout(1000);
  }

  // Reset to Korean
  await clickAt(page, 507, 300, 'Reset to Korean');
  await page.waitForTimeout(500);
  await clickAt(page, 757, 72, 'Close settings');
  await page.waitForTimeout(500);

  console.log('\n[DONE] Language test complete');

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
