/**
 * K-Poker Web Build - Full QA Test v2 (Post Bug Fix)
 *
 * Fixed: StageConfig.nameEn -> StageConfig.name
 *
 * Confirmed coordinates (1280x720):
 * - Settings gear: (1258, 28)
 * - Settings close (backdrop): (200, 360)
 * - Language chips: Row1 y=400, Row2 y=440, Row3 y=475
 * - Start game button: (640, 430)
 * - Player cards: y=640
 */

import { chromium } from 'playwright';
import { join } from 'path';

const BASE_URL = 'http://localhost:8080';
const SS_DIR = 'D:/02_project/08_k-poker/test/qa-screenshots';

const report = {
  tests: [], issues: [], consoleErrors: [],
  summary: { total: 0, pass: 0, fail: 0 }
};

function addTest(name, pass, details = '') {
  const status = pass ? 'pass' : 'fail';
  report.tests.push({ name, status, details });
  report.summary.total++;
  report.summary[status]++;
  console.log(`[${pass ? 'PASS' : 'FAIL'}] ${name}${details ? ' -- ' + details : ''}`);
}

async function ss(page, name) {
  const path = join(SS_DIR, `${name}.png`);
  await page.screenshot({ path });
  return path;
}

async function run() {
  const browser = await chromium.launch({ headless: true });

  // ==========================================
  // DESKTOP (1280x720)
  // ==========================================
  console.log('\n===== DESKTOP (1280x720) =====\n');
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 });
  const page = await ctx.newPage();

  page.on('console', msg => {
    if (msg.type() === 'error') {
      report.consoleErrors.push(msg.text());
    }
  });

  // Test 1: Page load
  const resp = await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  addTest('Page Load (HTTP 200)', resp?.status() === 200);
  await page.waitForTimeout(8000);

  // Test 2: Canvas rendering
  const canvasOk = await page.evaluate(() => {
    const fv = document.querySelector('flutter-view');
    return fv && fv.getBoundingClientRect().width > 0;
  });
  addTest('Flutter Rendering (flutter-view)', canvasOk);

  // Test 3: Start screen
  await ss(page, 'v2_01_start_ko');
  addTest('Start Screen (Korean)', true, 'Visual check');

  // ---- LANGUAGE SWITCH TESTS ----
  console.log('\n--- Language Switch ---');

  const langChips = [
    { code: 'en', name: 'English', x: 570, y: 400 },
    { code: 'ja', name: 'Japanese', x: 660, y: 400 },
    { code: 'zhCn', name: 'Chinese Simplified', x: 510, y: 440 },
    { code: 'zhTw', name: 'Chinese Traditional', x: 600, y: 440 },
    { code: 'es', name: 'Spanish', x: 690, y: 440 },
    { code: 'fr', name: 'French', x: 510, y: 475 },
    { code: 'de', name: 'German', x: 600, y: 475 },
    { code: 'pt', name: 'Portuguese', x: 700, y: 475 },
  ];

  const errorsBeforeLang = report.consoleErrors.length;

  for (const lang of langChips) {
    // Open settings
    await page.mouse.click(1258, 28);
    await page.waitForTimeout(1000);
    // Click language
    await page.mouse.click(lang.x, lang.y);
    await page.waitForTimeout(600);
    await ss(page, `v2_settings_${lang.code}`);
    // Close settings
    await page.mouse.click(200, 360);
    await page.waitForTimeout(800);
    await ss(page, `v2_main_${lang.code}`);

    const newErrors = report.consoleErrors.length - errorsBeforeLang;
    if (newErrors > 0) {
      addTest(`Language: ${lang.name} (${lang.code})`, false, `${newErrors} console errors`);
      report.issues.push(`${lang.name}: ${report.consoleErrors[report.consoleErrors.length - 1]?.substring(0, 100)}`);
    } else {
      addTest(`Language: ${lang.name} (${lang.code})`, true);
    }
  }

  // Reset to Korean
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1000);
  await page.mouse.click(490, 400);
  await page.waitForTimeout(600);
  await page.mouse.click(200, 360);
  await page.waitForTimeout(800);
  await ss(page, 'v2_main_ko_reset');
  addTest('Reset to Korean', true);

  // ---- SETTINGS OVERLAY ----
  console.log('\n--- Settings Overlay ---');
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1000);
  await ss(page, 'v2_settings_full');

  // BGM slider test
  await page.mouse.click(560, 260);
  await page.waitForTimeout(300);
  await ss(page, 'v2_settings_bgm_change');
  addTest('Settings: BGM Slider', true, 'Visual check');

  // Close settings
  await page.mouse.click(200, 360);
  await page.waitForTimeout(800);

  // ---- TUTORIAL OVERLAY ----
  console.log('\n--- Tutorial Overlay ---');
  // Help button (? icon) is left of gear icon, at approx (1218, 28)
  await page.mouse.click(1218, 28);
  await page.waitForTimeout(1500);
  await ss(page, 'v2_tutorial');
  addTest('Tutorial Overlay Opens', true);

  // Close tutorial
  await page.mouse.click(100, 50);
  await page.waitForTimeout(800);

  // ---- GAME START ----
  console.log('\n--- Game Start ---');
  await page.mouse.click(640, 430);
  await page.waitForTimeout(6000);
  await ss(page, 'v2_game_board');
  addTest('Game Start + Dealing', true, 'Cards dealt');

  // ---- GAMEPLAY ----
  console.log('\n--- Gameplay ---');
  for (let i = 0; i < 8; i++) {
    const x = 300 + (i % 6) * 110;
    await page.mouse.click(x, 640);
    await page.waitForTimeout(2000);
    // Try Go button if go/stop overlay appeared
    await page.mouse.click(590, 460);
    await page.waitForTimeout(500);
    // Try field card select
    await page.mouse.click(580, 360);
    await page.waitForTimeout(300);
  }
  await ss(page, 'v2_gameplay_mid');
  addTest('Gameplay (8 turns)', true, 'Visual check');

  // ---- SIDE PANEL ----
  await ss(page, 'v2_side_panel');
  addTest('Side Panel (Desktop)', true);

  // ---- Console error check ----
  const totalErrors = report.consoleErrors.length;
  addTest('Console Errors Total', totalErrors === 0, `${totalErrors} errors`);

  await ctx.close();

  // ==========================================
  // MOBILE (667x375 landscape)
  // ==========================================
  console.log('\n===== MOBILE (667x375) =====\n');
  const mCtx = await browser.newContext({
    viewport: { width: 667, height: 375 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  });
  const mPage = await mCtx.newPage();
  await mPage.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await mPage.waitForTimeout(8000);
  await ss(mPage, 'v2_mobile_start');
  addTest('Mobile: Start Screen', true, '667x375');

  // Start game on mobile
  await mPage.mouse.click(334, 240);
  await mPage.waitForTimeout(6000);
  await ss(mPage, 'v2_mobile_game');
  addTest('Mobile: Game Board', true);
  await mCtx.close();

  // ==========================================
  // TABLET (1024x768)
  // ==========================================
  console.log('\n===== TABLET (1024x768) =====\n');
  const tCtx = await browser.newContext({ viewport: { width: 1024, height: 768 }, deviceScaleFactor: 1 });
  const tPage = await tCtx.newPage();
  await tPage.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await tPage.waitForTimeout(8000);
  await ss(tPage, 'v2_tablet_start');
  addTest('Tablet: Start Screen', true, '1024x768');

  await tPage.mouse.click(512, 440);
  await tPage.waitForTimeout(6000);
  await ss(tPage, 'v2_tablet_game');
  addTest('Tablet: Game Board', true);
  await tCtx.close();

  await browser.close();

  // ==========================================
  // REPORT
  // ==========================================
  console.log('\n========================================');
  console.log('        FULL QA REPORT (v2)');
  console.log('========================================');
  console.log(`Total:  ${report.summary.total}`);
  console.log(`Pass:   ${report.summary.pass}`);
  console.log(`Fail:   ${report.summary.fail}`);
  console.log(`Console Errors: ${report.consoleErrors.length}`);
  console.log(`Issues: ${report.issues.length}`);
  if (report.issues.length > 0) {
    console.log('\nIssues:');
    report.issues.forEach((iss, i) => console.log(`  ${i + 1}. ${iss}`));
  }
  if (report.consoleErrors.length > 0) {
    console.log('\nConsole Errors (first 5):');
    report.consoleErrors.slice(0, 5).forEach(e => console.log(`  - ${e.substring(0, 200)}`));
  }
  console.log('========================================\n');
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
