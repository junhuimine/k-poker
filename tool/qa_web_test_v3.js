/**
 * K-Poker Web Build QA Test v3
 *
 * Strategy: Use Playwright with proper GPU/WebGL flags for Flutter CanvasKit.
 * Also try to diagnose exactly what's happening with the Flutter load.
 */
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'http://127.0.0.1:8888';
const SCREENSHOT_DIR = path.join(__dirname, '..', 'qa_screenshots');

if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

function log(msg) {
  console.log(`[QA] ${msg}`);
}

async function screenshot(page, name) {
  const filePath = path.join(SCREENSHOT_DIR, `${name}.png`);
  await page.screenshot({ path: filePath });
  return filePath;
}

async function main() {
  log('K-Poker Web Build QA - Diagnostics');

  // Try with new headless mode which has better GPU support
  const browser = await chromium.launch({
    headless: false,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--enable-webgl',
      '--enable-webgl2',
      '--ignore-gpu-blocklist',
      '--enable-gpu-rasterization',
      '--enable-features=VaapiVideoDecoder',
      '--use-gl=angle',
      '--use-angle=swiftshader',
      '--enable-unsafe-swiftshader',
      '--disable-software-rasterizer',
    ]
  });

  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
  });

  const page = await context.newPage();

  // Capture ALL console messages for diagnostics
  const allConsole = [];
  page.on('console', msg => {
    allConsole.push(`[${msg.type()}] ${msg.text()}`);
  });
  page.on('pageerror', err => {
    allConsole.push(`[PAGE_ERROR] ${err.message}`);
  });

  // Step 1: Load and diagnose
  log('Step 1: Navigating to app...');
  await page.goto(BASE_URL, { waitUntil: 'load', timeout: 60000 });

  log('Step 2: Waiting 5s for initial scripts...');
  await page.waitForTimeout(5000);

  // Diagnose DOM state
  const domState1 = await page.evaluate(() => {
    const result = {
      title: document.title,
      bodyHTML: document.body.innerHTML.substring(0, 2000),
      bodyChildCount: document.body.children.length,
      children: Array.from(document.body.children).map(c => ({
        tag: c.tagName,
        id: c.id,
        className: c.className,
        hasShadow: !!c.shadowRoot,
        style: c.style?.cssText?.substring(0, 200),
      })),
      canvases: document.querySelectorAll('canvas').length,
      webglSupport: (() => {
        try {
          const c = document.createElement('canvas');
          return !!c.getContext('webgl2') || !!c.getContext('webgl');
        } catch(e) { return false; }
      })(),
    };
    return result;
  });

  log(`DOM State after 5s:`);
  log(`  Title: ${domState1.title}`);
  log(`  Children: ${domState1.bodyChildCount}`);
  log(`  WebGL: ${domState1.webglSupport}`);
  log(`  Canvases: ${domState1.canvases}`);
  domState1.children.forEach((c, i) => {
    log(`  Child ${i}: <${c.tag}> id=${c.id} class=${c.className} shadow=${c.hasShadow}`);
  });

  await screenshot(page, 'diag_01_5s');

  // Wait longer
  log('Step 3: Waiting 15s more...');
  await page.waitForTimeout(15000);

  const domState2 = await page.evaluate(() => {
    const result = {
      bodyChildCount: document.body.children.length,
      children: Array.from(document.body.children).map(c => ({
        tag: c.tagName,
        id: c.id,
        hasShadow: !!c.shadowRoot,
        childCount: c.children ? c.children.length : 0,
        shadowChildCount: c.shadowRoot ? c.shadowRoot.children.length : 0,
      })),
      canvases: document.querySelectorAll('canvas').length,
      allCanvasInfo: Array.from(document.querySelectorAll('canvas')).map(c => ({
        width: c.width,
        height: c.height,
        style: c.style?.cssText?.substring(0, 100),
      })),
    };

    // Also check shadow DOM for canvases
    const shadowHosts = Array.from(document.querySelectorAll('*')).filter(el => el.shadowRoot);
    result.shadowHosts = shadowHosts.length;
    result.shadowCanvases = 0;
    shadowHosts.forEach(host => {
      result.shadowCanvases += host.shadowRoot.querySelectorAll('canvas').length;
    });

    return result;
  });

  log(`DOM State after 20s:`);
  log(`  Children: ${domState2.bodyChildCount}`);
  log(`  Canvases (light DOM): ${domState2.canvases}`);
  log(`  Shadow hosts: ${domState2.shadowHosts}`);
  log(`  Canvases (shadow DOM): ${domState2.shadowCanvases}`);
  domState2.children.forEach((c, i) => {
    log(`  Child ${i}: <${c.tag}> id=${c.id} shadow=${c.hasShadow} children=${c.childCount} shadowChildren=${c.shadowChildCount}`);
  });
  if (domState2.allCanvasInfo.length > 0) {
    domState2.allCanvasInfo.forEach((c, i) => {
      log(`  Canvas ${i}: ${c.width}x${c.height} style="${c.style}"`);
    });
  }

  await screenshot(page, 'diag_02_20s');

  // Wait even longer
  log('Step 4: Waiting 20s more...');
  await page.waitForTimeout(20000);

  const domState3 = await page.evaluate(() => {
    const result = {
      canvases: document.querySelectorAll('canvas').length,
      bodyChildCount: document.body.children.length,
      fullBodyHTML: document.body.innerHTML.substring(0, 3000),
    };

    // Deep search: check all shadow DOMs recursively
    function findCanvasesInShadow(root) {
      let count = 0;
      const elements = root.querySelectorAll('*');
      for (const el of elements) {
        if (el.tagName === 'CANVAS') count++;
        if (el.shadowRoot) count += findCanvasesInShadow(el.shadowRoot);
      }
      return count;
    }
    result.deepCanvases = findCanvasesInShadow(document);

    return result;
  });

  log(`DOM State after 40s:`);
  log(`  Canvases (light): ${domState3.canvases}`);
  log(`  Canvases (deep): ${domState3.deepCanvases}`);
  log(`  Body HTML: ${domState3.fullBodyHTML.substring(0, 500)}`);

  await screenshot(page, 'diag_03_40s');

  // Print all console messages
  log('\nAll Console Messages:');
  allConsole.forEach(m => log(`  ${m.substring(0, 300)}`));

  await browser.close();
  log('\nDiagnostics complete.');
}

main().catch(e => {
  console.error('Fatal:', e);
  process.exit(1);
});
