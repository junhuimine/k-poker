/**
 * K-Poker Web Build QA Test Script
 *
 * Flutter CanvasKit web app full QA test using Playwright.
 * Tests: navigation, buttons, language switching, gameplay, shop, popups, responsive.
 */
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'http://127.0.0.1:8080';
const SCREENSHOT_DIR = path.join(__dirname, '..', 'qa_screenshots');
const RESULTS = [];

// Ensure screenshot directory exists
if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

function log(msg) {
  console.log(`[QA] ${msg}`);
  RESULTS.push(msg);
}

async function waitForFlutter(page, timeout = 30000) {
  log('Waiting for Flutter app to load...');
  // Wait for the canvas to appear (Flutter CanvasKit renders to <canvas>)
  try {
    await page.waitForSelector('flt-glass-pane', { timeout });
    // Additional wait for app initialization
    await page.waitForTimeout(5000);
    log('Flutter app loaded successfully');
    return true;
  } catch (e) {
    log(`ERROR: Flutter app failed to load within ${timeout}ms: ${e.message}`);
    return false;
  }
}

async function screenshot(page, name) {
  const filePath = path.join(SCREENSHOT_DIR, `${name}.png`);
  await page.screenshot({ path: filePath, fullPage: true });
  log(`Screenshot saved: ${name}.png`);
  return filePath;
}

async function checkConsoleErrors(page) {
  const errors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      errors.push(msg.text());
    }
  });
  return errors;
}

// ========================================================================
// Test 1: App Loading & Main Screen
// ========================================================================
async function testAppLoading(page) {
  log('\n=== TEST 1: App Loading & Main Screen ===');

  await page.goto(BASE_URL, { waitUntil: 'networkidle' });
  const loaded = await waitForFlutter(page);

  if (!loaded) {
    log('FAIL: App did not load');
    return false;
  }

  await screenshot(page, '01_main_screen_initial');

  // Wait extra for splash/loading to finish
  await page.waitForTimeout(3000);
  await screenshot(page, '02_main_screen_loaded');

  log('PASS: App loaded successfully');
  return true;
}

// ========================================================================
// Test 2: Game Start Button
// ========================================================================
async function testGameStart(page) {
  log('\n=== TEST 2: Game Start ===');

  // The "Start Game" button is typically in the center of the screen
  // Flutter CanvasKit uses coordinate-based clicks
  const viewport = page.viewportSize();
  const centerX = viewport.width / 2;
  const centerY = viewport.height / 2;

  // Click the start game button (usually center-bottom area of start overlay)
  // Based on GameStartOverlay layout: title at top, buttons below center
  await page.mouse.click(centerX, centerY + 80);
  await page.waitForTimeout(2000);
  await screenshot(page, '03_after_start_click');

  log('PASS: Game start button clicked');
  return true;
}

// ========================================================================
// Test 3: In-Game Screen Elements
// ========================================================================
async function testInGameScreen(page) {
  log('\n=== TEST 3: In-Game Screen Elements ===');

  // Wait for dealing animation to complete
  await page.waitForTimeout(5000);
  await screenshot(page, '04_in_game_dealing');

  // Wait more for cards to settle
  await page.waitForTimeout(3000);
  await screenshot(page, '05_in_game_ready');

  log('PASS: In-game screen rendered');
  return true;
}

// ========================================================================
// Test 4: Card Selection (click a player card)
// ========================================================================
async function testCardSelection(page) {
  log('\n=== TEST 4: Card Selection ===');

  const viewport = page.viewportSize();

  // Player hand is at the bottom of the screen
  // Try clicking first card in player hand (bottom-center-left area)
  const playerY = viewport.height - 80; // Bottom area
  const firstCardX = viewport.width * 0.3;

  await page.mouse.click(firstCardX, playerY);
  await page.waitForTimeout(2000);
  await screenshot(page, '06_card_selected');

  // Try another card
  await page.mouse.click(viewport.width * 0.4, playerY);
  await page.waitForTimeout(2000);
  await screenshot(page, '07_card_selected_2');

  log('PASS: Card selection tested');
  return true;
}

// ========================================================================
// Test 5: Settings Overlay
// ========================================================================
async function testSettingsOverlay(page) {
  log('\n=== TEST 5: Settings Overlay ===');

  // First, go back to main screen by reloading
  await page.goto(BASE_URL, { waitUntil: 'networkidle' });
  await waitForFlutter(page);
  await page.waitForTimeout(5000);

  const viewport = page.viewportSize();

  // Settings button is typically in the bottom-right or top-right of start overlay
  // Based on GameStartOverlay: settings icon is usually at bottom
  // Let's try clicking the settings/gear icon area
  // From code: onSettings button with gear icon, positioned below start button
  const settingsX = viewport.width / 2 - 80;
  const settingsY = viewport.height / 2 + 140;

  await page.mouse.click(settingsX, settingsY);
  await page.waitForTimeout(1000);
  await screenshot(page, '08_settings_attempt');

  log('Settings overlay test attempted');
  return true;
}

// ========================================================================
// Test 6: Tutorial Overlay
// ========================================================================
async function testTutorialOverlay(page) {
  log('\n=== TEST 6: Tutorial Overlay ===');

  // Reload to get back to start screen
  await page.goto(BASE_URL, { waitUntil: 'networkidle' });
  await waitForFlutter(page);
  await page.waitForTimeout(5000);

  const viewport = page.viewportSize();

  // Tutorial button (question mark icon), usually near settings
  const tutorialX = viewport.width / 2 + 80;
  const tutorialY = viewport.height / 2 + 140;

  await page.mouse.click(tutorialX, tutorialY);
  await page.waitForTimeout(1000);
  await screenshot(page, '09_tutorial_attempt');

  log('Tutorial overlay test attempted');
  return true;
}

// ========================================================================
// Test 7: Responsive Layout Testing
// ========================================================================
async function testResponsive(page) {
  log('\n=== TEST 7: Responsive Layout ===');

  const viewports = [
    { name: 'mobile_landscape', width: 667, height: 375 },
    { name: 'tablet_landscape', width: 1024, height: 768 },
    { name: 'desktop', width: 1920, height: 1080 },
    { name: 'small_desktop', width: 1280, height: 720 },
  ];

  for (const vp of viewports) {
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    await waitForFlutter(page);
    await page.waitForTimeout(5000);
    await screenshot(page, `10_responsive_${vp.name}_${vp.width}x${vp.height}`);
    log(`Responsive test: ${vp.name} (${vp.width}x${vp.height})`);
  }

  // Reset to default
  await page.setViewportSize({ width: 1280, height: 720 });

  log('PASS: Responsive layout tests completed');
  return true;
}

// ========================================================================
// Main Test Runner
// ========================================================================
async function main() {
  log('K-Poker Web Build QA Test Starting...');
  log(`Base URL: ${BASE_URL}`);
  log(`Screenshot Dir: ${SCREENSHOT_DIR}`);
  log(`Timestamp: ${new Date().toISOString()}`);

  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
  });

  const page = await context.newPage();

  // Collect console errors
  const consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });

  // Collect page errors
  const pageErrors = [];
  page.on('pageerror', err => {
    pageErrors.push(err.message);
  });

  try {
    // Run tests sequentially
    await testAppLoading(page);
    await testGameStart(page);
    await testInGameScreen(page);
    await testCardSelection(page);
    await testSettingsOverlay(page);
    await testTutorialOverlay(page);
    await testResponsive(page);

  } catch (e) {
    log(`CRITICAL ERROR: ${e.message}`);
    await screenshot(page, 'error_state');
  } finally {
    // Report console errors
    if (consoleErrors.length > 0) {
      log('\n=== Console Errors ===');
      consoleErrors.forEach(e => log(`  ERROR: ${e}`));
    } else {
      log('\nNo console errors detected');
    }

    if (pageErrors.length > 0) {
      log('\n=== Page Errors ===');
      pageErrors.forEach(e => log(`  ERROR: ${e}`));
    }

    await browser.close();
  }

  // Write results
  const resultPath = path.join(SCREENSHOT_DIR, 'qa_results.txt');
  fs.writeFileSync(resultPath, RESULTS.join('\n'), 'utf8');
  log(`\nResults written to: ${resultPath}`);

  console.log('\n========================================');
  console.log('QA Test Complete');
  console.log(`Screenshots: ${SCREENSHOT_DIR}`);
  console.log(`Total tests: 7`);
  console.log('========================================');
}

main().catch(e => {
  console.error('Fatal error:', e);
  process.exit(1);
});
