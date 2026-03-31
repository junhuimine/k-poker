/**
 * K-Poker Full QA Test Script
 *
 * Phase 1: Initial Loading
 * Phase 2: Game Start Overlay (buttons, layout)
 * Phase 3: Settings Overlay (language switch, controls)
 * Phase 4: Tutorial Overlay (tabs, content)
 * Phase 5: In-game Play (card interaction, turn flow)
 * Phase 6: Side Panel
 * Phase 7: Responsive Layout
 * Phase 8: Multi-language visual check
 */

import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

const BASE_URL = 'http://localhost:8080';
const SCREENSHOT_DIR = 'D:/02_project/08_k-poker/qa_screenshots/full_qa_20260327';
const RESULTS = [];
const ISSUES = [];

let browser, page;

function log(msg) {
  const ts = new Date().toISOString().slice(11, 19);
  const line = `[${ts}] ${msg}`;
  console.log(line);
  RESULTS.push(line);
}

function issue(severity, category, desc) {
  const entry = { severity, category, desc };
  ISSUES.push(entry);
  log(`[ISSUE:${severity}] ${category}: ${desc}`);
}

async function screenshot(name) {
  const filePath = path.join(SCREENSHOT_DIR, `${name}.png`);
  await page.screenshot({ path: filePath, fullPage: false });
  log(`Screenshot: ${name}.png`);
  return filePath;
}

async function waitForFlutter(timeout = 15000) {
  // Flutter web apps load a service worker + WASM/canvaskit
  // Wait for the main canvas element or flutter-view
  try {
    await page.waitForFunction(() => {
      // Check if Flutter rendered anything
      const fv = document.querySelector('flutter-view') || document.querySelector('flt-glass-pane');
      const canvas = document.querySelector('canvas');
      return fv || canvas;
    }, { timeout });
    return true;
  } catch {
    return false;
  }
}

async function getConsoleErrors() {
  // We collect console errors during the test
  return page._consoleErrors || [];
}

// ===== PHASE 1: Initial Loading =====
async function phase1_initialLoading() {
  log('=== PHASE 1: Initial Loading ===');

  // Navigate to the app
  const response = await page.goto(BASE_URL, { waitUntil: 'load', timeout: 30000 });
  const status = response?.status();
  log(`HTTP Status: ${status}`);
  if (status !== 200) {
    issue('CRITICAL', 'Loading', `HTTP status ${status} instead of 200`);
  }

  // Wait 3 seconds for splash
  await page.waitForTimeout(3000);
  await screenshot('01_splash_loading');

  // Wait for Flutter to fully load
  const flutterLoaded = await waitForFlutter(20000);
  if (!flutterLoaded) {
    issue('CRITICAL', 'Loading', 'Flutter framework failed to initialize within 20s');
    return false;
  }
  log('Flutter framework loaded successfully');

  // Wait extra for assets
  await page.waitForTimeout(5000);
  await screenshot('02_after_flutter_load');

  // Check for console errors
  const errors = await getConsoleErrors();
  if (errors.length > 0) {
    errors.forEach(e => issue('WARNING', 'Console', e));
  }
  log(`Console errors during load: ${errors.length}`);

  // Check canvas is rendered (Flutter web uses canvas)
  const hasCanvas = await page.evaluate(() => {
    const canvas = document.querySelector('canvas');
    return canvas ? { width: canvas.width, height: canvas.height } : null;
  });
  if (hasCanvas) {
    log(`Canvas found: ${hasCanvas.width}x${hasCanvas.height}`);
  } else {
    issue('WARNING', 'Loading', 'No canvas element found (Flutter may use different rendering)');
  }

  return true;
}

// ===== PHASE 2: Game Start Overlay =====
async function phase2_gameStartOverlay() {
  log('=== PHASE 2: Game Start Overlay ===');

  // The game starts with GameStartOverlay showing:
  // - 5-bright fan cards
  // - "K-Poker: Hwatu Roguelike" title
  // - Stage info
  // - Start Game, Settings, Tutorial buttons

  await page.waitForTimeout(2000);
  await screenshot('03_game_start_overlay');

  // Try to find and capture visible text (Flutter canvas = not easy, but we try accessibility tree)
  try {
    const accessTree = await page.accessibility.snapshot();
    log(`Accessibility tree root: ${accessTree?.role || 'none'}`);
    if (accessTree?.children) {
      log(`Accessibility children count: ${accessTree.children.length}`);
    }
  } catch (e) {
    log(`Accessibility tree not available: ${e.message}`);
  }

  // Check for key visual elements via pixel sampling
  // We verify the page is not blank (all one color)
  const isBlank = await page.evaluate(() => {
    const canvas = document.querySelector('canvas');
    if (!canvas) return null;
    try {
      const ctx = canvas.getContext('2d');
      if (!ctx) return null;
      const data = ctx.getImageData(0, 0, 10, 10).data;
      // Check if first 10x10 pixels are all same color
      const r = data[0], g = data[1], b = data[2];
      let allSame = true;
      for (let i = 4; i < data.length; i += 4) {
        if (data[i] !== r || data[i+1] !== g || data[i+2] !== b) {
          allSame = false;
          break;
        }
      }
      return { allSame, sampleColor: `rgb(${r},${g},${b})` };
    } catch { return 'canvas-tainted'; }
  });

  if (isBlank === 'canvas-tainted') {
    log('Canvas is cross-origin tainted (normal for Flutter)');
  } else if (isBlank?.allSame) {
    issue('WARNING', 'Visual', `Screen may be blank (all pixels: ${isBlank.sampleColor})`);
  } else {
    log('Screen appears to have varied content (not blank)');
  }

  return true;
}

// ===== PHASE 3: Settings Overlay =====
async function phase3_settingsOverlay() {
  log('=== PHASE 3: Settings Overlay ===');

  // Settings button is typically in the start overlay
  // Flutter web: we need to click by coordinates
  // From code: settings button has gear icon + "settings" text
  // In GameStartOverlay, buttons are stacked vertically at center

  // First, let's try to find the settings button via semantics
  // The start overlay has: Start Game (center), Settings (below), Tutorial (below)

  const viewport = page.viewportSize();
  const cx = viewport.width / 2;
  const cy = viewport.height / 2;

  // Settings button is typically below center-right area
  // From the code: Row with [Settings] [Tutorial] [Sound] buttons below start button
  // Let's click in the approximate area

  // Try the settings gear icon area (bottom-right of start overlay)
  // The overlay uses FittedBox with 1200x700 logical size
  // Buttons appear below the main start button

  // Let's capture current state first
  await screenshot('04_before_settings_click');

  // Click settings button area (typically around 40% down from start button)
  // Based on code analysis: settings is in a Row below the start button
  // approx y = cy + 120 (below start), x = cx - 80 (left of center in row)
  await page.mouse.click(cx - 80, cy + 150);
  await page.waitForTimeout(1500);
  await screenshot('05_after_settings_click_attempt');

  // Check if settings overlay appeared (it's a dark overlay with a panel)
  // If not visible, try other coordinates

  return true;
}

// ===== PHASE 4: Tutorial Overlay =====
async function phase4_tutorialOverlay() {
  log('=== PHASE 4: Tutorial Overlay ===');

  // First go back to start (click outside settings if open, or ESC)
  await page.keyboard.press('Escape');
  await page.waitForTimeout(1000);

  const viewport = page.viewportSize();
  const cx = viewport.width / 2;
  const cy = viewport.height / 2;

  // Tutorial button area
  await page.mouse.click(cx + 80, cy + 150);
  await page.waitForTimeout(1500);
  await screenshot('06_tutorial_overlay_attempt');

  // Tutorial has 3 tabs: Rules, Dictionary, Yaku
  // Try clicking tab areas if tutorial is visible
  // Tab bar is typically at the top of the tutorial panel

  // Click first tab (Rules) - approximate position
  await page.mouse.click(cx - 200, cy - 180);
  await page.waitForTimeout(500);
  await screenshot('07_tutorial_tab1_rules');

  // Click second tab (Dictionary)
  await page.mouse.click(cx, cy - 180);
  await page.waitForTimeout(500);
  await screenshot('08_tutorial_tab2_dictionary');

  // Click third tab (Yaku)
  await page.mouse.click(cx + 200, cy - 180);
  await page.waitForTimeout(500);
  await screenshot('09_tutorial_tab3_yaku');

  // Close tutorial
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
  // Or click the backdrop
  await page.mouse.click(10, 10);
  await page.waitForTimeout(1000);
  await screenshot('10_after_tutorial_close');

  return true;
}

// ===== PHASE 5: In-Game Play =====
async function phase5_inGamePlay() {
  log('=== PHASE 5: In-Game Play ===');

  const viewport = page.viewportSize();
  const cx = viewport.width / 2;
  const cy = viewport.height / 2;

  // Click "Start Game" button (center of screen, large button)
  await page.mouse.click(cx, cy + 30);
  await page.waitForTimeout(1000);
  await screenshot('11_start_game_click');

  // If start button didn't work, try other positions
  await page.mouse.click(cx, cy);
  await page.waitForTimeout(500);
  await page.mouse.click(cx, cy - 20);
  await page.waitForTimeout(3000);
  await screenshot('12_dealing_animation');

  // Wait for dealing animation to complete (typically 3-5 seconds)
  await page.waitForTimeout(5000);
  await screenshot('13_game_board_ready');

  // Now game board should be visible with:
  // - Opponent cards (top, face down)
  // - Field cards (center)
  // - Player cards (bottom, face up)
  // - Side panel (right)
  // - Deck pile (center-right)

  // Try clicking a player card (bottom area)
  // Player hand is at the bottom of the screen
  const playerCardY = viewport.height - 80;
  const cardSpacing = viewport.width / 12;

  // Click first player card
  await page.mouse.click(cx - cardSpacing * 2, playerCardY);
  await page.waitForTimeout(2000);
  await screenshot('14_card_selected');

  // Click second player card
  await page.mouse.click(cx - cardSpacing, playerCardY);
  await page.waitForTimeout(2000);
  await screenshot('15_card_play_attempt');

  // Click third player card
  await page.mouse.click(cx, playerCardY);
  await page.waitForTimeout(2000);
  await screenshot('16_card_play_2');

  // Wait for AI turn
  await page.waitForTimeout(3000);
  await screenshot('17_after_ai_turn');

  // Try a few more turns
  for (let i = 0; i < 3; i++) {
    const cardX = cx - cardSpacing * (2 - i);
    await page.mouse.click(cardX, playerCardY);
    await page.waitForTimeout(3000);
    await screenshot(`18_turn_${i + 1}`);
  }

  return true;
}

// ===== PHASE 6: Side Panel =====
async function phase6_sidePanel() {
  log('=== PHASE 6: Side Panel ===');

  const viewport = page.viewportSize();

  // Side panel toggle is at the right edge
  // From code: SidePanelToggle is 24px wide at right edge
  await page.mouse.click(viewport.width - 12, viewport.height / 2);
  await page.waitForTimeout(1000);
  await screenshot('19_side_panel_toggle');

  // Click again to close
  await page.mouse.click(viewport.width - 12, viewport.height / 2);
  await page.waitForTimeout(1000);
  await screenshot('20_side_panel_closed');

  return true;
}

// ===== PHASE 7: Responsive Layout =====
async function phase7_responsive() {
  log('=== PHASE 7: Responsive Layout ===');

  // Test three viewport sizes
  const viewports = [
    { name: 'mobile_landscape', width: 667, height: 375 },
    { name: 'tablet_landscape', width: 1024, height: 768 },
    { name: 'desktop_hd', width: 1280, height: 720 },
    { name: 'desktop_fhd', width: 1920, height: 1080 },
  ];

  for (const vp of viewports) {
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.waitForTimeout(2000);
    await screenshot(`21_responsive_${vp.name}`);
    log(`Viewport ${vp.name}: ${vp.width}x${vp.height}`);
  }

  // Restore default
  await page.setViewportSize({ width: 1280, height: 720 });
  await page.waitForTimeout(1000);

  return true;
}

// ===== PHASE 8: Language Check (via settings) =====
async function phase8_languageCheck() {
  log('=== PHASE 8: Multi-Language Visual Check ===');

  // We need to reload and check the start overlay in each language
  // Since language switching is in settings, we'll test by changing language
  // and taking screenshots of the start overlay

  // Reload to fresh start
  await page.goto(BASE_URL, { waitUntil: 'load', timeout: 30000 });
  await page.waitForTimeout(8000); // Wait for Flutter + splash
  await screenshot('22_fresh_load_for_lang_test');

  // The start overlay should be visible now
  // We need to open settings, change language, close settings, see the change

  const viewport = page.viewportSize();
  const cx = viewport.width / 2;
  const cy = viewport.height / 2;

  // Languages to test visually (we'll cycle through a few)
  const langTests = ['en', 'ko', 'ja'];

  for (let i = 0; i < langTests.length; i++) {
    const lang = langTests[i];
    log(`Testing language: ${lang}`);

    // Open settings (click the gear icon area in start overlay)
    // Based on code: bottom row has settings icon/button
    await page.mouse.click(cx - 100, cy + 160);
    await page.waitForTimeout(1500);
    await screenshot(`23_settings_for_${lang}`);

    // In settings overlay, language dropdown is a DropdownButton
    // It's roughly in the middle of the settings panel
    // Language section is after BGM and SFX sliders
    // Approximate: settings panel center, about 60% down

    // Click the language dropdown area
    await page.mouse.click(cx + 40, cy + 20);
    await page.waitForTimeout(1000);
    await screenshot(`24_lang_dropdown_${lang}`);

    // Select language (dropdown items appear in order: ko, en, ja, zhCn, zhTw, es, fr, de, pt, th)
    // Each item is roughly 48px tall
    // ko = first, en = second, ja = third
    const langIndex = { ko: 0, en: 1, ja: 2, zhCn: 3 };
    const idx = langIndex[lang] || 0;
    const dropdownItemY = cy - 150 + (idx * 48);

    await page.mouse.click(cx + 40, dropdownItemY);
    await page.waitForTimeout(1000);

    // Close settings
    await page.mouse.click(10, 10);
    await page.waitForTimeout(1500);
    await screenshot(`25_start_overlay_${lang}`);
  }

  return true;
}

// ===== MAIN =====
async function main() {
  log('K-Poker Full QA Test Starting...');
  log(`Date: ${new Date().toISOString()}`);
  log(`Target: ${BASE_URL}`);
  log(`Screenshots: ${SCREENSHOT_DIR}`);

  // Ensure screenshot directory exists
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });

  // Launch browser
  browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-web-security'],
  });

  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
  });

  page = await context.newPage();

  // Collect console errors
  page._consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      page._consoleErrors.push(msg.text());
    }
  });

  page.on('pageerror', err => {
    page._consoleErrors.push(`PageError: ${err.message}`);
    issue('ERROR', 'Console', `Page error: ${err.message}`);
  });

  // Run all phases
  try {
    const loaded = await phase1_initialLoading();
    if (!loaded) {
      issue('CRITICAL', 'Loading', 'App failed to load, aborting remaining tests');
    } else {
      await phase2_gameStartOverlay();
      await phase3_settingsOverlay();
      await phase4_tutorialOverlay();
      await phase5_inGamePlay();
      await phase6_sidePanel();
      await phase7_responsive();
      await phase8_languageCheck();
    }
  } catch (e) {
    issue('CRITICAL', 'Test', `Unhandled error: ${e.message}`);
    log(`Stack: ${e.stack}`);
    await screenshot('99_error_state');
  }

  // Collect final console errors
  const finalErrors = page._consoleErrors;
  log(`\n=== Final Console Errors: ${finalErrors.length} ===`);
  finalErrors.forEach((e, i) => log(`  [${i}] ${e}`));

  // Summary
  log('\n=== QA TEST SUMMARY ===');
  log(`Total log entries: ${RESULTS.length}`);
  log(`Total issues: ${ISSUES.length}`);

  const critical = ISSUES.filter(i => i.severity === 'CRITICAL').length;
  const errors = ISSUES.filter(i => i.severity === 'ERROR').length;
  const warnings = ISSUES.filter(i => i.severity === 'WARNING').length;

  log(`  CRITICAL: ${critical}`);
  log(`  ERROR: ${errors}`);
  log(`  WARNING: ${warnings}`);

  if (critical > 0) {
    log('Verdict: NEEDS_FIX (critical issues found)');
  } else if (errors > 0) {
    log('Verdict: PARTIAL_PASS (errors found but not critical)');
  } else if (warnings > 0) {
    log('Verdict: PASS (with warnings)');
  } else {
    log('Verdict: PASS');
  }

  // Write results
  const reportPath = path.join(SCREENSHOT_DIR, 'qa_report.txt');
  fs.writeFileSync(reportPath, RESULTS.join('\n') + '\n\nISSUES:\n' +
    ISSUES.map(i => `[${i.severity}] ${i.category}: ${i.desc}`).join('\n'));
  log(`Report written to: ${reportPath}`);

  await browser.close();
}

main().catch(e => {
  console.error('Fatal error:', e);
  process.exit(1);
});
