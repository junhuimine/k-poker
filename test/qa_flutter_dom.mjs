/**
 * Flutter DOM structure inspector
 * Check how Flutter web handles click events and find the actual event target
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

  // Inspect DOM structure
  const domInfo = await page.evaluate(() => {
    const body = document.body;
    const allElements = document.querySelectorAll('*');
    const elementList = [];
    for (const el of allElements) {
      const rect = el.getBoundingClientRect();
      if (rect.width > 0 && rect.height > 0) {
        elementList.push({
          tag: el.tagName.toLowerCase(),
          id: el.id || '',
          class: el.className || '',
          x: Math.round(rect.x),
          y: Math.round(rect.y),
          w: Math.round(rect.width),
          h: Math.round(rect.height),
          style: el.style?.cssText?.substring(0, 100) || '',
        });
      }
    }
    return elementList;
  });

  console.log('=== DOM Elements with dimensions ===');
  for (const el of domInfo) {
    console.log(`<${el.tag}${el.id ? '#' + el.id : ''}> ${el.w}x${el.h} at (${el.x},${el.y})${el.class ? ' class="' + String(el.class).substring(0, 50) + '"' : ''}`);
  }

  // Check the event handling layer
  const glassPane = await page.evaluate(() => {
    const gp = document.querySelector('flt-glass-pane');
    if (!gp) return null;
    const rect = gp.getBoundingClientRect();
    const shadow = gp.shadowRoot;
    let shadowChildren = [];
    if (shadow) {
      for (const child of shadow.children) {
        const cRect = child.getBoundingClientRect();
        shadowChildren.push({
          tag: child.tagName.toLowerCase(),
          id: child.id,
          w: Math.round(cRect.width),
          h: Math.round(cRect.height),
          x: Math.round(cRect.x),
          y: Math.round(cRect.y),
          style: child.style?.cssText?.substring(0, 200) || '',
        });
      }
    }
    return {
      rect: { x: Math.round(rect.x), y: Math.round(rect.y), w: Math.round(rect.width), h: Math.round(rect.height) },
      hasShadow: !!shadow,
      shadowChildCount: shadow ? shadow.children.length : 0,
      shadowChildren,
      pointerEvents: window.getComputedStyle(gp).pointerEvents,
    };
  });

  console.log('\n=== flt-glass-pane ===');
  console.log(JSON.stringify(glassPane, null, 2));

  // Try enabling Flutter semantics by clicking the placeholder
  console.log('\n=== Trying to enable Flutter semantics ===');
  const semPlaceholder = await page.evaluate(() => {
    const el = document.querySelector('flt-semantics-placeholder');
    if (el) {
      const rect = el.getBoundingClientRect();
      return { x: rect.x, y: rect.y, w: rect.width, h: rect.height };
    }
    return null;
  });
  console.log('Semantics placeholder:', semPlaceholder);

  // Enable semantics
  if (semPlaceholder) {
    // The placeholder is a hidden button - we need to focus and click it
    await page.evaluate(() => {
      const el = document.querySelector('flt-semantics-placeholder');
      if (el) el.click();
    });
    await page.waitForTimeout(2000);

    // Check if semantics nodes appeared
    const semNodes = await page.evaluate(() => {
      const gp = document.querySelector('flt-glass-pane');
      if (!gp || !gp.shadowRoot) return [];
      const nodes = gp.shadowRoot.querySelectorAll('flt-semantics');
      return [...nodes].map(n => ({
        role: n.getAttribute('role'),
        label: n.getAttribute('aria-label'),
        rect: (() => {
          const r = n.getBoundingClientRect();
          return { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) };
        })(),
      })).filter(n => n.label || n.role).slice(0, 80);
    });

    console.log(`\nSemantics nodes found: ${semNodes.length}`);
    for (const node of semNodes) {
      console.log(`  [${node.role || '?'}] "${node.label || ''}" at (${node.rect.x},${node.rect.y}) ${node.rect.w}x${node.rect.h}`);
    }
  }

  // Open settings and re-check
  console.log('\n=== Opening settings overlay... ===');
  // Click gear icon area
  await page.mouse.click(1258, 28);
  await page.waitForTimeout(1500);
  await page.screenshot({ path: join(SCREENSHOT_DIR, 'dom_settings.png') });

  // Re-check semantics after settings opened
  const semAfterSettings = await page.evaluate(() => {
    const gp = document.querySelector('flt-glass-pane');
    if (!gp || !gp.shadowRoot) return [];
    const nodes = gp.shadowRoot.querySelectorAll('flt-semantics');
    return [...nodes].map(n => ({
      role: n.getAttribute('role'),
      label: n.getAttribute('aria-label'),
      rect: (() => {
        const r = n.getBoundingClientRect();
        return { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) };
      })(),
    })).filter(n => (n.label || n.role) && n.rect.w > 0).slice(0, 100);
  });

  console.log(`\nSemantics after settings: ${semAfterSettings.length} nodes`);
  for (const node of semAfterSettings) {
    console.log(`  [${node.role || '?'}] "${node.label || ''}" at (${node.rect.x},${node.rect.y}) ${node.rect.w}x${node.rect.h}`);
  }

  await context.close();
  await browser.close();
}

run().catch(e => {
  console.error('[FATAL]', e);
  process.exit(1);
});
