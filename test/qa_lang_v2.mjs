/**
 * K-Poker Language Switch Test v2 - Precision Coordinates
 *
 * Settings overlay layout (1280x720 viewport):
 * - Overlay box: centered, 360px wide = x range [460, 820]
 * - Close by clicking OUTSIDE the box: x=200, y=360 (left empty area)
 * - Settings gear icon: top-right, approximately (1258, 28)
 *
 * Language chips from the screenshot analysis:
 * The chips are in a Wrap widget with spacing=6, runSpacing=6
 * Each chip has padding: horizontal 10, vertical 6
 * Chip labels include flag emoji + text
 *
 * From the actual 1280x720 screenshot:
 * - Settings box spans approximately x=460 to x=820, y=47 to y=668
 * - "언어" section header at approximately y=268
 * - Language chips start at approximately y=293
 *   Row 1: 한국어(x~500), English(x~582), 日本語(x~658)
 *   Row 2: 简体中文(x~510), 繁體中文(x~602), Español(x~690)
 *   Row 3: Français(x~510), Deutsch(x~594), Português(x~688)
 *   Row 4: ภาษาไทย(x~510)
 *
 * The X close button of the settings is in the header row:
 * - IconButton at top-right of the 360px box
 * - Approximately at x=787, y=67
 */

import { chromium } from 'playwright';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SCREENSHOT_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';
const results = [];

async function clickAt(page, x, y, desc = '') {
  if (desc) console.log(`  [CLICK] ${desc} at (${x}, ${y})`);
  await page.mouse.click(x, y);
  await page.waitForTimeout(500);
}

async function ss(page, name) {
  const path = join(SCREENSHOT_DIR, `${name}.png`);
  await page.screenshot({ path });
  console.log(`  [SS] ${name}.png`);
}

async function run() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
  });
  const page = await context.newPage();
  await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(8000); // Flutter full load

  // The expected button text for "Start Game" in each language:
  const expectedButtonText = {
    ko: '게임 시작',
    en: 'Start Game',
    ja: 'ゲーム開始',
    zhCn: '开始游戏',
    zhTw: '開始遊戲',
    es: 'Iniciar Juego',
    fr: 'Commencer',
    de: 'Spiel starten',
    pt: 'Iniciar Jogo',
    th: 'เริ่มเกม',
  };

  // Screenshot baseline (should be Korean)
  await ss(page, 'v2_00_baseline');

  // Define language chip coordinates
  // I'll use a more careful estimation based on the overlay layout
  // Settings overlay: centered at (640, 360), width=360, height=max 85% of 720=612
  // Content starts at: overlay top + padding(24) + header(~40) + divider + ...

  // Better approach: click outside to close, then verify main screen
  const langChips = [
    { code: 'en', name: 'English', x: 582, y: 295 },
    { code: 'ja', name: 'Japanese', x: 658, y: 295 },
    { code: 'zhCn', name: 'Ch.Simplified', x: 510, y: 333 },
    { code: 'zhTw', name: 'Ch.Traditional', x: 602, y: 333 },
    { code: 'es', name: 'Spanish', x: 690, y: 333 },
    { code: 'fr', name: 'French', x: 510, y: 370 },
    { code: 'de', name: 'German', x: 594, y: 370 },
    { code: 'pt', name: 'Portuguese', x: 688, y: 370 },
    { code: 'th', name: 'Thai', x: 510, y: 407 },
    { code: 'ko', name: 'Korean', x: 500, y: 295 }, // last to reset
  ];

  for (const lang of langChips) {
    console.log(`\n=== ${lang.name} (${lang.code}) ===`);

    // 1. Open settings (click gear icon in top-right)
    await clickAt(page, 1258, 28, 'Open settings');
    await page.waitForTimeout(800);

    // 2. Take settings screenshot to verify it opened
    await ss(page, `v2_settings_before_${lang.code}`);

    // 3. Click the language chip
    await clickAt(page, lang.x, lang.y, `Click ${lang.name} chip`);
    await page.waitForTimeout(600);

    // 4. Take settings screenshot to show selection changed
    await ss(page, `v2_settings_selected_${lang.code}`);

    // 5. Close settings by clicking OUTSIDE the overlay box (left area)
    await clickAt(page, 200, 360, 'Close settings (click outside)');
    await page.waitForTimeout(800);

    // 6. Screenshot main screen to verify language changed
    await ss(page, `v2_main_${lang.code}`);

    console.log(`  [OK] ${lang.name} done`);
  }

  console.log('\n[DONE] All language tests complete');
  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
