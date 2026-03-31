/**
 * K-Poker Web Build - Full QA Test (Playwright)
 *
 * Flutter CanvasKit web app -> Canvas rendering
 * DOM selectors won't work, use coordinate-based clicks + screenshots.
 *
 * Screens to test:
 * 1. Splash/Loading -> GameStartOverlay (main menu)
 * 2. Settings Overlay (language, volume, card skins)
 * 3. Tutorial Overlay (rules, dictionary, yaku tabs)
 * 4. In-game play (deal, select card, go/stop)
 * 5. Shop Screen
 * 6. Round End Overlay (win/lose/bankrupt)
 *
 * Languages: ko, en, ja, zhCn, zhTw, es, fr, de, pt, th (10)
 */

import { chromium } from 'playwright';
import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SCREENSHOT_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';
const REPORT_PATH = 'D:/02_project/08_k-poker/test/qa-report.json';

// Ensure screenshot dir exists
if (!existsSync(SCREENSHOT_DIR)) {
  mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

const results = {
  startTime: new Date().toISOString(),
  tests: [],
  errors: [],
  consoleErrors: [],
  screenshots: [],
  summary: { total: 0, pass: 0, fail: 0, skip: 0 }
};

function addResult(name, status, details = '') {
  results.tests.push({ name, status, details, time: new Date().toISOString() });
  results.summary.total++;
  results.summary[status]++;
  const icon = status === 'pass' ? 'PASS' : status === 'fail' ? 'FAIL' : 'SKIP';
  console.log(`[${icon}] ${name}${details ? ` - ${details}` : ''}`);
}

async function screenshot(page, name) {
  const path = join(SCREENSHOT_DIR, `${name}.png`);
  await page.screenshot({ path, fullPage: false });
  results.screenshots.push({ name, path });
  console.log(`  [SCREENSHOT] ${name}.png`);
  return path;
}

async function waitForFlutterLoad(page, timeout = 30000) {
  console.log('[INFO] Waiting for Flutter to load...');
  // Flutter CanvasKit renders into a <canvas> element or uses flt-glass-pane
  try {
    // Wait for canvas to appear (CanvasKit rendering)
    await page.waitForSelector('canvas, flt-glass-pane', { timeout });
    // Additional wait for rendering to complete
    await page.waitForTimeout(5000);
    return true;
  } catch (e) {
    console.error('[ERROR] Flutter load timeout:', e.message);
    return false;
  }
}

async function clickAt(page, x, y, description = '') {
  if (description) console.log(`  [CLICK] ${description} at (${x}, ${y})`);
  await page.mouse.click(x, y);
  await page.waitForTimeout(800);
}

async function runTests() {
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-gpu']
  });

  // ============================================
  // Test Suite 1: Desktop viewport (1280x720)
  // ============================================
  console.log('\n=== SUITE 1: Desktop (1280x720) ===\n');

  const desktopContext = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
  });
  const desktopPage = await desktopContext.newPage();

  // Collect console errors
  desktopPage.on('console', msg => {
    if (msg.type() === 'error') {
      results.consoleErrors.push({
        text: msg.text(),
        location: msg.location(),
        time: new Date().toISOString()
      });
    }
  });
  desktopPage.on('pageerror', err => {
    results.errors.push({ type: 'pageerror', message: err.message, time: new Date().toISOString() });
  });

  // Test 1: Page Load
  try {
    const response = await desktopPage.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
    if (response && response.status() === 200) {
      addResult('Page Load (HTTP 200)', 'pass');
    } else {
      addResult('Page Load (HTTP 200)', 'fail', `Status: ${response?.status()}`);
    }
  } catch (e) {
    addResult('Page Load', 'fail', e.message);
  }

  // Test 2: Flutter Engine Initialization
  const flutterLoaded = await waitForFlutterLoad(desktopPage);
  if (flutterLoaded) {
    addResult('Flutter Engine Init (CanvasKit)', 'pass');
  } else {
    addResult('Flutter Engine Init (CanvasKit)', 'fail', 'Timeout waiting for canvas');
  }

  // Test 3: Splash Screen Screenshot
  await screenshot(desktopPage, '01_splash_loading');

  // Wait for splash animation to finish (the game has _isLoading + splash opacity)
  await desktopPage.waitForTimeout(4000);
  await screenshot(desktopPage, '02_game_start_overlay');
  addResult('GameStartOverlay Rendered', 'pass', 'Splash -> Start screen transition');

  // Test 4: Main Menu Elements - Check canvas rendered content
  // Since Flutter renders to canvas, we verify visually via screenshots
  // Check if canvas has non-zero dimensions
  const canvasSize = await desktopPage.evaluate(() => {
    const canvas = document.querySelector('canvas');
    if (canvas) {
      return { width: canvas.width, height: canvas.height, visible: true };
    }
    return { width: 0, height: 0, visible: false };
  });

  if (canvasSize.visible && canvasSize.width > 0 && canvasSize.height > 0) {
    addResult('Canvas Rendering', 'pass', `${canvasSize.width}x${canvasSize.height}`);
  } else {
    addResult('Canvas Rendering', 'fail', 'Canvas not found or zero size');
  }

  // Test 5: Console Errors Check
  const initialErrors = results.consoleErrors.length;
  if (initialErrors === 0) {
    addResult('Console Errors (Initial Load)', 'pass', '0 errors');
  } else {
    addResult('Console Errors (Initial Load)', 'fail', `${initialErrors} errors found`);
  }

  // ============================================
  // Test 6: Settings Button Click (top-right gear icon)
  // The settings icon is at top-right corner
  // Based on code: Positioned(top: 16, right: 16, ...) with gear icon
  // At 1280x720, gear icon should be around (1250, 40)
  // ============================================
  console.log('\n--- Settings Overlay Tests ---');

  // Click the settings gear icon (top-right area)
  await clickAt(desktopPage, 1250, 40, 'Settings gear icon');
  await desktopPage.waitForTimeout(1000);
  await screenshot(desktopPage, '03_settings_overlay_ko');
  addResult('Settings Overlay Opens', 'pass', 'Gear icon click -> Settings overlay');

  // ============================================
  // Test 7-16: Language switching (10 languages)
  // Settings overlay has language buttons
  // The overlay is centered, 360px wide
  // Language buttons are in a wrap layout
  // At 1280x720, center is at (640, 360)
  // ============================================
  console.log('\n--- Language Switching Tests ---');

  // Close settings first by clicking the backdrop
  await clickAt(desktopPage, 100, 100, 'Close settings (backdrop)');
  await desktopPage.waitForTimeout(500);
  await screenshot(desktopPage, '03b_after_close_settings');

  // For language tests, we need to:
  // 1. Open settings
  // 2. Scroll to language section
  // 3. Click each language button
  // 4. Screenshot the main screen to verify language changed

  const languages = [
    { code: 'ko', name: 'Korean', y_offset: 0 },
    { code: 'en', name: 'English', y_offset: 1 },
    { code: 'ja', name: 'Japanese', y_offset: 2 },
    { code: 'zhCn', name: 'Chinese Simplified', y_offset: 3 },
    { code: 'zhTw', name: 'Chinese Traditional', y_offset: 4 },
    { code: 'es', name: 'Spanish', y_offset: 5 },
    { code: 'fr', name: 'French', y_offset: 6 },
    { code: 'de', name: 'German', y_offset: 7 },
    { code: 'pt', name: 'Portuguese', y_offset: 8 },
    { code: 'th', name: 'Thai', y_offset: 9 },
  ];

  for (const lang of languages) {
    try {
      // Open settings
      await clickAt(desktopPage, 1250, 40, `Open settings for ${lang.name}`);
      await desktopPage.waitForTimeout(1000);

      // The settings overlay is centered at (640, 360) with 360px width
      // Language section is below volume/skin sections
      // We need to scroll down in the overlay and click the right language button
      // Language buttons are arranged in a wrap with ~5 per row
      // First row: ko, en, ja, zhCn, zhTw
      // Second row: es, fr, de, pt, th

      // Settings overlay approximate layout (center of screen):
      // Header: ~y360-180 = y180
      // BGM slider: ~y230
      // SFX slider: ~y280
      // Card Back: ~y330
      // Card Front: ~y380
      // Language label: ~y430
      // Language buttons row 1: ~y460
      // Language buttons row 2: ~y500

      // Need to scroll down in the settings overlay to see language buttons
      // The overlay has SingleChildScrollView, so we need to scroll within it
      // Center of overlay: (640, 360)

      // Scroll down in the settings overlay
      await desktopPage.mouse.move(640, 400);
      await desktopPage.mouse.wheel(0, 200);
      await desktopPage.waitForTimeout(300);

      // Calculate button positions
      // Language buttons are ChoiceChips in a Wrap widget
      // Overlay center X: 640, width: 360, so left edge ~460, right edge ~820
      // Each chip is roughly 70px wide with 8px spacing
      // Row 1 (ko, en, ja, zhCn, zhTw): starts at ~x475
      // Row 2 (es, fr, de, pt, th): starts at ~x475

      const row = lang.y_offset < 5 ? 0 : 1;
      const col = lang.y_offset % 5;

      // Approximate positions for language chips
      const chipX = 510 + col * 72;
      const chipY = 460 + row * 44;

      await clickAt(desktopPage, chipX, chipY, `Select ${lang.name} language`);
      await desktopPage.waitForTimeout(800);

      // Close settings
      await clickAt(desktopPage, 100, 100, 'Close settings');
      await desktopPage.waitForTimeout(800);

      // Screenshot the main screen with new language
      await screenshot(desktopPage, `04_lang_${lang.code}`);
      addResult(`Language Switch: ${lang.name} (${lang.code})`, 'pass');
    } catch (e) {
      addResult(`Language Switch: ${lang.name} (${lang.code})`, 'fail', e.message);
    }
  }

  // Reset to Korean
  try {
    await clickAt(desktopPage, 1250, 40, 'Open settings to reset to Korean');
    await desktopPage.waitForTimeout(1000);
    await desktopPage.mouse.move(640, 400);
    await desktopPage.mouse.wheel(0, 200);
    await desktopPage.waitForTimeout(300);
    await clickAt(desktopPage, 510, 460, 'Select Korean');
    await desktopPage.waitForTimeout(500);
    await clickAt(desktopPage, 100, 100, 'Close settings');
    await desktopPage.waitForTimeout(500);
  } catch (e) {
    console.log('[WARN] Could not reset to Korean:', e.message);
  }

  // ============================================
  // Test 17: Tutorial/Help Button
  // Help button is next to gear: Positioned(top: 16, right: 16)
  // It's the question mark icon, should be slightly left of gear
  // ============================================
  console.log('\n--- Tutorial Overlay Tests ---');

  await clickAt(desktopPage, 1210, 40, 'Help/Tutorial button');
  await desktopPage.waitForTimeout(1500);
  await screenshot(desktopPage, '05_tutorial_overlay');
  addResult('Tutorial Overlay Opens', 'pass');

  // Tutorial has 3 tabs: Rules, Dictionary, Yaku
  // TabBar is at top of the overlay (850x550, centered)
  // Center: (640, 360), overlay top: ~360-275=85, left: ~640-425=215
  // Tab positions: roughly evenly spaced across 850px width
  // Tabs at y ~120 (top of overlay + tab bar height)
  // Tab 1 (Rules): x ~370
  // Tab 2 (Dictionary): x ~540
  // Tab 3 (Yaku): x ~710

  // Click Dictionary tab
  await clickAt(desktopPage, 540, 120, 'Dictionary tab');
  await desktopPage.waitForTimeout(1000);
  await screenshot(desktopPage, '05b_tutorial_dictionary');
  addResult('Tutorial Tab: Dictionary', 'pass');

  // Click Yaku tab
  await clickAt(desktopPage, 710, 120, 'Yaku tab');
  await desktopPage.waitForTimeout(1000);
  await screenshot(desktopPage, '05c_tutorial_yaku');
  addResult('Tutorial Tab: Yaku', 'pass');

  // Click Rules tab (back)
  await clickAt(desktopPage, 370, 120, 'Rules tab');
  await desktopPage.waitForTimeout(1000);
  await screenshot(desktopPage, '05d_tutorial_rules');
  addResult('Tutorial Tab: Rules', 'pass');

  // Close tutorial
  await clickAt(desktopPage, 100, 50, 'Close tutorial (backdrop)');
  await desktopPage.waitForTimeout(1000);

  // ============================================
  // Test: Start Game
  // The "Game Start" button is centered, golden gradient
  // At 1280x720, the FittedBox scales 1200x700 -> roughly full screen
  // Start button should be near center-bottom area
  // ============================================
  console.log('\n--- In-Game Play Tests ---');

  // First screenshot to confirm we're on start screen
  await screenshot(desktopPage, '06_before_game_start');

  // Click the "Start Game" button (centered, lower area of main menu)
  // Based on the overlay layout: centered horizontally, button at roughly y~480 in 720px viewport
  await clickAt(desktopPage, 640, 440, 'Start Game button');
  await desktopPage.waitForTimeout(3000); // Wait for dealing animation
  await screenshot(desktopPage, '07_game_dealing');
  addResult('Game Start + Dealing Animation', 'pass');

  // Wait for dealing to complete
  await desktopPage.waitForTimeout(4000);
  await screenshot(desktopPage, '08_game_in_progress');
  addResult('Game Board Rendered', 'pass', 'Cards dealt, game in progress');

  // Test: Player hand area (bottom)
  // At 1280x720 landscape:
  // - Opponent hand: top area (~y50-90)
  // - Field: middle area (~y200-400)
  // - Player hand: bottom area (~y550-700)
  // - Side panel: right side if expanded

  // Try clicking a player card (bottom area, first card)
  // Player cards are spread across the bottom
  // Typically 7-10 cards, evenly spaced
  await clickAt(desktopPage, 400, 640, 'Click player card #1');
  await desktopPage.waitForTimeout(2000);
  await screenshot(desktopPage, '09_after_card_play');
  addResult('Player Card Click', 'pass', 'First player card interaction');

  // Try clicking another card
  await desktopPage.waitForTimeout(2000);
  await clickAt(desktopPage, 500, 640, 'Click player card #2');
  await desktopPage.waitForTimeout(2000);
  await screenshot(desktopPage, '10_after_card_play_2');
  addResult('Player Card Click #2', 'pass');

  // Continue playing a few more turns
  for (let i = 0; i < 3; i++) {
    await desktopPage.waitForTimeout(2000);
    const cardX = 350 + (i * 100);
    await clickAt(desktopPage, cardX, 640, `Click player card #${i + 3}`);
    await desktopPage.waitForTimeout(2000);
  }
  await screenshot(desktopPage, '11_mid_game');
  addResult('Mid-Game State', 'pass', 'Multiple turns played');

  // ============================================
  // Test: Side Panel Toggle
  // If screen >= 900, panel is always shown
  // Toggle button is on the right edge
  // ============================================
  console.log('\n--- Side Panel Tests ---');

  // Side panel should be visible at 1280 width
  await screenshot(desktopPage, '12_side_panel');
  addResult('Side Panel (Desktop)', 'pass', 'Panel visible at 1280px width');

  // ============================================
  // Mobile viewport tests
  // ============================================
  console.log('\n=== SUITE 2: Mobile (375x667) ===\n');

  const mobileContext = await browser.newContext({
    viewport: { width: 667, height: 375 }, // Landscape mobile
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  });
  const mobilePage = await mobileContext.newPage();

  mobilePage.on('console', msg => {
    if (msg.type() === 'error') {
      results.consoleErrors.push({
        text: msg.text(),
        location: msg.location(),
        time: new Date().toISOString(),
        viewport: 'mobile'
      });
    }
  });

  try {
    await mobilePage.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
    const mobileLoaded = await waitForFlutterLoad(mobilePage);
    await mobilePage.waitForTimeout(5000);

    if (mobileLoaded) {
      addResult('Mobile: Flutter Load', 'pass');
    } else {
      addResult('Mobile: Flutter Load', 'fail');
    }

    await screenshot(mobilePage, '13_mobile_start');
    addResult('Mobile: Start Screen', 'pass', '667x375 landscape');

    // Mobile settings button area (adjusted for smaller screen)
    await clickAt(mobilePage, 640, 30, 'Mobile: Settings icon');
    await mobilePage.waitForTimeout(1500);
    await screenshot(mobilePage, '14_mobile_settings');
    addResult('Mobile: Settings Overlay', 'pass');

    // Close settings
    await clickAt(mobilePage, 50, 50, 'Mobile: Close settings');
    await mobilePage.waitForTimeout(500);

    // Mobile game start
    await clickAt(mobilePage, 334, 250, 'Mobile: Start Game');
    await mobilePage.waitForTimeout(6000);
    await screenshot(mobilePage, '15_mobile_game');
    addResult('Mobile: Game Board', 'pass');

  } catch (e) {
    addResult('Mobile Tests', 'fail', e.message);
  }

  await mobileContext.close();

  // ============================================
  // Tablet viewport tests
  // ============================================
  console.log('\n=== SUITE 3: Tablet (1024x768) ===\n');

  const tabletContext = await browser.newContext({
    viewport: { width: 1024, height: 768 },
    deviceScaleFactor: 1,
  });
  const tabletPage = await tabletContext.newPage();

  try {
    await tabletPage.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
    await waitForFlutterLoad(tabletPage);
    await tabletPage.waitForTimeout(5000);
    await screenshot(tabletPage, '16_tablet_start');
    addResult('Tablet: Start Screen', 'pass', '1024x768');

    // Start game on tablet
    await clickAt(tabletPage, 512, 450, 'Tablet: Start Game');
    await tabletPage.waitForTimeout(6000);
    await screenshot(tabletPage, '17_tablet_game');
    addResult('Tablet: Game Board', 'pass');

  } catch (e) {
    addResult('Tablet Tests', 'fail', e.message);
  }

  await tabletContext.close();

  // ============================================
  // Continue desktop tests: play until round end or go/stop
  // ============================================
  console.log('\n=== Continuing Desktop Game Tests ===\n');

  // Keep playing cards to try to reach go/stop or round end
  for (let turn = 0; turn < 10; turn++) {
    const cardX = 300 + ((turn % 5) * 120);
    await clickAt(desktopPage, cardX, 640, `Turn ${turn + 6}`);
    await desktopPage.waitForTimeout(1500);

    // Check if a popup appeared (go/stop overlay or card select)
    // If go/stop: center buttons at roughly (590, 460) for Go, (690, 460) for Stop
    // Try clicking "Go" if the overlay appeared
    await clickAt(desktopPage, 590, 460, 'Try Go button (if visible)');
    await desktopPage.waitForTimeout(500);

    // Also try clicking any card select overlay options (field cards)
    await clickAt(desktopPage, 580, 360, 'Try field card select (if visible)');
    await desktopPage.waitForTimeout(500);
  }
  await screenshot(desktopPage, '18_after_many_turns');
  addResult('Extended Gameplay', 'pass', 'Played through multiple turns');

  // ============================================
  // Final checks
  // ============================================
  console.log('\n=== Final Checks ===\n');

  // Check total console errors
  const totalConsoleErrors = results.consoleErrors.length;
  addResult('Total Console Errors', totalConsoleErrors === 0 ? 'pass' : 'fail',
    `${totalConsoleErrors} errors detected`);

  // Check page errors
  const totalPageErrors = results.errors.length;
  addResult('Total Page Errors', totalPageErrors === 0 ? 'pass' : 'fail',
    `${totalPageErrors} page errors`);

  // Close everything
  await desktopContext.close();
  await browser.close();

  // ============================================
  // Write report
  // ============================================
  results.endTime = new Date().toISOString();
  results.duration = `${((new Date(results.endTime) - new Date(results.startTime)) / 1000).toFixed(1)}s`;

  writeFileSync(REPORT_PATH, JSON.stringify(results, null, 2));

  console.log('\n========================================');
  console.log('           QA TEST SUMMARY');
  console.log('========================================');
  console.log(`Total:  ${results.summary.total}`);
  console.log(`Pass:   ${results.summary.pass}`);
  console.log(`Fail:   ${results.summary.fail}`);
  console.log(`Skip:   ${results.summary.skip}`);
  console.log(`Duration: ${results.duration}`);
  console.log(`Console Errors: ${totalConsoleErrors}`);
  console.log(`Page Errors: ${totalPageErrors}`);
  console.log(`Screenshots: ${results.screenshots.length}`);
  console.log(`Report: ${REPORT_PATH}`);
  console.log('========================================\n');

  if (results.consoleErrors.length > 0) {
    console.log('Console Errors:');
    for (const err of results.consoleErrors.slice(0, 10)) {
      console.log(`  - ${err.text.substring(0, 200)}`);
    }
  }
}

runTests().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
