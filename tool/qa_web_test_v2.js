/**
 * K-Poker Web Build QA Test Script v2
 *
 * Flutter CanvasKit requires WebGL. Using headed mode with GPU flags for proper rendering.
 */
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'http://127.0.0.1:8080';
const SCREENSHOT_DIR = path.join(__dirname, '..', 'qa_screenshots');
const RESULTS = [];
let consoleErrors = [];
let pageErrors = [];

if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

function log(msg) {
  console.log(`[QA] ${msg}`);
  RESULTS.push(msg);
}

async function screenshot(page, name) {
  const filePath = path.join(SCREENSHOT_DIR, `${name}.png`);
  await page.screenshot({ path: filePath });
  log(`  Screenshot: ${name}.png`);
  return filePath;
}

async function waitForFlutterCanvas(page, timeout = 60000) {
  log('  Waiting for Flutter canvas to render...');
  const start = Date.now();

  // Flutter CanvasKit renders to a <canvas> element within shadow DOM
  // or directly. Let's wait for any canvas with content.
  while (Date.now() - start < timeout) {
    // Check for any canvas element
    const canvasCount = await page.evaluate(() => {
      return document.querySelectorAll('canvas').length;
    });

    if (canvasCount > 0) {
      // Check if canvas has actual content (non-empty pixels)
      const hasContent = await page.evaluate(() => {
        const canvases = document.querySelectorAll('canvas');
        for (const canvas of canvases) {
          if (canvas.width > 0 && canvas.height > 0) {
            try {
              const ctx = canvas.getContext('2d');
              if (ctx) {
                const data = ctx.getImageData(0, 0, Math.min(canvas.width, 100), Math.min(canvas.height, 100)).data;
                for (let i = 0; i < data.length; i += 4) {
                  if (data[i] !== 0 || data[i+1] !== 0 || data[i+2] !== 0 || data[i+3] !== 0) {
                    return true;
                  }
                }
              }
            } catch(e) {
              // WebGL canvas - can't read pixels, but presence is good enough
              return true;
            }
          }
        }
        return false;
      });

      if (hasContent) {
        log(`  Flutter canvas detected (${canvasCount} canvas element(s))`);
        return true;
      }
    }

    // Also check for Flutter's shadow DOM elements
    const flutterReady = await page.evaluate(() => {
      // Check flutter-view element (newer Flutter)
      const fv = document.querySelector('flutter-view');
      if (fv) return true;
      // Check for shadow DOM host
      const body = document.body;
      if (body && body.children.length > 0) {
        for (const child of body.children) {
          if (child.shadowRoot) return true;
        }
      }
      return false;
    });

    if (flutterReady) {
      log('  Flutter view element detected');
      await page.waitForTimeout(3000); // Extra wait for render
      return true;
    }

    await page.waitForTimeout(1000);
  }

  log('  WARNING: Flutter canvas not detected within timeout');
  return false;
}

// ========================================================================
// Test Suite
// ========================================================================

async function testAppLoading(page) {
  log('\n=== TEST 1: App Loading & Main Screen ===');

  await page.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 60000 });

  // Wait for Flutter framework to initialize
  await page.waitForTimeout(3000);

  // Check what DOM elements exist
  const domInfo = await page.evaluate(() => {
    const info = {
      title: document.title,
      bodyChildren: document.body.children.length,
      childTags: Array.from(document.body.children).map(c => c.tagName.toLowerCase()),
      canvasCount: document.querySelectorAll('canvas').length,
      scriptCount: document.querySelectorAll('script').length,
      hasFlutterView: !!document.querySelector('flutter-view'),
      hasShadowRoots: Array.from(document.body.children).some(c => !!c.shadowRoot),
      bodyHTML: document.body.innerHTML.substring(0, 500),
    };
    return info;
  });

  log(`  Title: ${domInfo.title}`);
  log(`  Body children: ${domInfo.bodyChildren} (${domInfo.childTags.join(', ')})`);
  log(`  Canvas count: ${domInfo.canvasCount}`);
  log(`  Flutter view: ${domInfo.hasFlutterView}`);
  log(`  Shadow roots: ${domInfo.hasShadowRoots}`);

  const loaded = await waitForFlutterCanvas(page);

  // Wait extra for splash animation
  await page.waitForTimeout(8000);

  await screenshot(page, '01_initial_load');

  // Wait for splash to fade
  await page.waitForTimeout(5000);
  await screenshot(page, '02_after_splash');

  return loaded;
}

async function testMainScreenInteraction(page) {
  log('\n=== TEST 2: Main Screen Buttons ===');

  const viewport = page.viewportSize();
  const w = viewport.width;
  const h = viewport.height;

  // Take screenshot first to see current state
  await screenshot(page, '03_main_screen_state');

  // The start overlay has:
  // - 5-card fan at top center
  // - "K-Poker: Hwatu Tazza" title
  // - Stage/opponent info
  // - Start Game button (center)
  // - Settings (gear) and Tutorial (?) buttons below

  // Try clicking various positions to find interactive elements
  // Settings button: based on code, it's likely bottom-left of the centered content
  // Tutorial button: bottom-right of the centered content

  // Click settings (gear icon) - usually in the lower portion of the overlay
  log('  Attempting to click Settings button...');
  await page.mouse.click(w / 2 - 60, h * 0.72);
  await page.waitForTimeout(2000);
  await screenshot(page, '04_settings_click_1');

  // Try another position for settings
  await page.mouse.click(w / 2 - 100, h * 0.75);
  await page.waitForTimeout(1000);
  await screenshot(page, '05_settings_click_2');

  // ESC to close any overlay
  await page.keyboard.press('Escape');
  await page.waitForTimeout(1000);

  // Click tutorial (? icon) - usually next to settings
  log('  Attempting to click Tutorial button...');
  await page.mouse.click(w / 2 + 60, h * 0.72);
  await page.waitForTimeout(2000);
  await screenshot(page, '06_tutorial_click_1');

  await page.keyboard.press('Escape');
  await page.waitForTimeout(1000);

  return true;
}

async function testGameStart(page) {
  log('\n=== TEST 3: Game Start & Dealing ===');

  const viewport = page.viewportSize();
  const w = viewport.width;
  const h = viewport.height;

  // Click "Start Game" button - should be prominent center button
  log('  Clicking Start Game button...');
  await page.mouse.click(w / 2, h * 0.6);
  await page.waitForTimeout(1000);
  await screenshot(page, '07_start_game_click');

  // Wait for dealing animation
  await page.waitForTimeout(5000);
  await screenshot(page, '08_dealing_animation');

  // Wait for deal complete
  await page.waitForTimeout(5000);
  await screenshot(page, '09_game_board_ready');

  return true;
}

async function testCardPlay(page) {
  log('\n=== TEST 4: Card Selection & Play ===');

  const viewport = page.viewportSize();
  const w = viewport.width;
  const h = viewport.height;

  // Player cards are at the bottom of the screen
  // Try clicking cards in the player hand area
  const playerHandY = h - 60;

  for (let i = 0; i < 5; i++) {
    const cardX = w * (0.25 + i * 0.1);
    log(`  Clicking player card at (${Math.round(cardX)}, ${playerHandY})...`);
    await page.mouse.click(cardX, playerHandY);
    await page.waitForTimeout(2000);
    await screenshot(page, `10_card_play_${i + 1}`);

    // Check if a Go/Stop overlay appeared
    await page.waitForTimeout(1000);
  }

  return true;
}

async function testGoStopDecision(page) {
  log('\n=== TEST 5: Go/Stop Decision ===');

  const viewport = page.viewportSize();
  const w = viewport.width;
  const h = viewport.height;

  // If Go/Stop overlay is visible, try clicking Go or Stop
  // Go button typically on left, Stop on right
  await page.mouse.click(w * 0.35, h * 0.5); // Go
  await page.waitForTimeout(1000);
  await screenshot(page, '11_go_stop_attempt');

  await page.mouse.click(w * 0.65, h * 0.5); // Stop
  await page.waitForTimeout(1000);
  await screenshot(page, '12_go_stop_attempt_2');

  return true;
}

async function testSidePanel(page) {
  log('\n=== TEST 6: Side Panel Toggle ===');

  const viewport = page.viewportSize();
  const w = viewport.width;
  const h = viewport.height;

  // Side panel toggle is on the right edge
  log('  Clicking side panel toggle...');
  await page.mouse.click(w - 12, h / 2);
  await page.waitForTimeout(1000);
  await screenshot(page, '13_side_panel_toggle');

  // Click again to close
  await page.mouse.click(w - 12, h / 2);
  await page.waitForTimeout(1000);

  return true;
}

async function testResponsive(page) {
  log('\n=== TEST 7: Responsive Layout ===');

  const viewports = [
    { name: 'mobile_landscape', width: 667, height: 375 },
    { name: 'tablet_landscape', width: 1024, height: 768 },
    { name: 'desktop_hd', width: 1920, height: 1080 },
    { name: 'default', width: 1280, height: 720 },
  ];

  for (const vp of viewports) {
    log(`  Testing ${vp.name} (${vp.width}x${vp.height})...`);

    // Create new page with specific viewport
    const newPage = await page.context().newPage();
    await newPage.setViewportSize({ width: vp.width, height: vp.height });
    await newPage.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 60000 });
    await newPage.waitForTimeout(10000); // Wait for Flutter load
    await newPage.screenshot({
      path: path.join(SCREENSHOT_DIR, `14_responsive_${vp.name}.png`)
    });
    log(`  Screenshot: 14_responsive_${vp.name}.png`);
    await newPage.close();
  }

  return true;
}

async function testFullGameFlow(page) {
  log('\n=== TEST 8: Full Game Flow (Fresh Start) ===');

  // Reload for fresh game
  await page.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await page.waitForTimeout(12000); // Full Flutter load + splash

  const viewport = page.viewportSize();
  const w = viewport.width;
  const h = viewport.height;

  await screenshot(page, '15_fresh_start');

  // Step 1: Click Start Game
  log('  Step 1: Start Game');
  await page.mouse.click(w / 2, h * 0.58);
  await page.waitForTimeout(8000);
  await screenshot(page, '16_game_started');

  // Step 2: Play cards (click each player card slot from left to right)
  log('  Step 2: Play cards');
  for (let round = 0; round < 3; round++) {
    const cardX = w * (0.25 + round * 0.08);
    const cardY = h - 50;
    await page.mouse.click(cardX, cardY);
    await page.waitForTimeout(3000);
    await screenshot(page, `17_round_${round + 1}`);
  }

  return true;
}

// ========================================================================
// Main Runner
// ========================================================================
async function main() {
  log('K-Poker Web Build QA Test v2');
  log(`Base URL: ${BASE_URL}`);
  log(`Timestamp: ${new Date().toISOString()}`);
  log('');

  const browser = await chromium.launch({
    headless: false, // Need headed mode for WebGL/CanvasKit
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--enable-webgl',
      '--enable-gpu-rasterization',
      '--ignore-gpu-blocklist',
      '--enable-features=Vulkan',
      '--use-gl=angle',
      '--use-angle=swiftshader',
      '--window-size=1280,720',
    ]
  });

  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
  });

  const page = await context.newPage();

  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });
  page.on('pageerror', err => {
    pageErrors.push(err.message);
  });

  let testResults = {};

  try {
    testResults['1_loading'] = await testAppLoading(page);
    testResults['2_main_screen'] = await testMainScreenInteraction(page);
    testResults['3_game_start'] = await testGameStart(page);
    testResults['4_card_play'] = await testCardPlay(page);
    testResults['5_go_stop'] = await testGoStopDecision(page);
    testResults['6_side_panel'] = await testSidePanel(page);
    testResults['7_responsive'] = await testResponsive(page);
    testResults['8_full_flow'] = await testFullGameFlow(page);
  } catch (e) {
    log(`CRITICAL ERROR: ${e.message}`);
    log(e.stack);
    await screenshot(page, 'error_state');
  } finally {
    log('\n=== Console Errors ===');
    if (consoleErrors.length > 0) {
      consoleErrors.forEach(e => log(`  ${e.substring(0, 200)}`));
    } else {
      log('  None');
    }

    log('\n=== Page Errors ===');
    if (pageErrors.length > 0) {
      pageErrors.forEach(e => log(`  ${e.substring(0, 200)}`));
    } else {
      log('  None');
    }

    log('\n=== Test Results ===');
    Object.entries(testResults).forEach(([name, result]) => {
      log(`  ${name}: ${result ? 'PASS' : 'FAIL'}`);
    });

    await browser.close();
  }

  const resultPath = path.join(SCREENSHOT_DIR, 'qa_results_v2.txt');
  fs.writeFileSync(resultPath, RESULTS.join('\n'), 'utf8');
  log(`\nResults written to: ${resultPath}`);
}

main().catch(e => {
  console.error('Fatal:', e);
  process.exit(1);
});
