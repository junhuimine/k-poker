import { chromium } from 'playwright';

async function main() {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await ctx.newPage();

  await page.goto('http://localhost:8080', { waitUntil: 'load', timeout: 30000 });

  // Check DOM every 2 seconds for 30 seconds
  for (let i = 0; i < 15; i++) {
    await page.waitForTimeout(2000);
    const info = await page.evaluate(() => {
      const html = document.documentElement.outerHTML.substring(0, 500);
      const allTags = [...document.querySelectorAll('*')].map(el => el.tagName.toLowerCase());
      const uniqueTags = [...new Set(allTags)];
      const bodyChildren = document.body ? [...document.body.children].map(c => c.tagName) : [];
      const hasCanvas = !!document.querySelector('canvas');
      const hasFlutterView = !!document.querySelector('flutter-view');
      const hasFltGlassPane = !!document.querySelector('flt-glass-pane');
      const hasShadowRoot = document.body?.firstElementChild?.shadowRoot ? true : false;
      return { uniqueTags: uniqueTags.join(','), bodyChildren: bodyChildren.join(','), hasCanvas, hasFlutterView, hasFltGlassPane, hasShadowRoot };
    });
    console.log(`[${(i+1)*2}s]`, JSON.stringify(info));
  }

  await page.screenshot({ path: 'D:/02_project/08_k-poker/qa_screenshots/full_qa_20260327/dom_check.png' });
  await browser.close();
}

main().catch(console.error);
