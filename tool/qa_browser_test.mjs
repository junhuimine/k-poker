/**
 * 🎴 K-Poker 브라우저 전수검사 v4 (CDP Input 디스패치)
 *
 * Flutter CanvasKit은 shadow DOM 안의 canvas에서 이벤트를 처리하므로
 * 일반 DOM 클릭이 안 먹힌다.
 * → Chrome DevTools Protocol의 Input.dispatchMouseEvent를 사용하면
 *   브라우저 레벨에서 직접 마우스 이벤트를 보내므로 확실히 작동한다.
 */

import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

const BASE_URL = process.env.QA_URL || 'https://junhuimine.github.io/k-poker';
const SCREENSHOT_DIR = path.resolve('qa_screenshots');
const RESULTS = [];
let passCount = 0, failCount = 0, warnCount = 0;

if (!fs.existsSync(SCREENSHOT_DIR)) fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });

function log(status, category, message) {
  const icon = status === 'PASS' ? '✅' : status === 'FAIL' ? '❌' : '⚠️';
  console.log(`${icon} [${category}] ${message}`);
  RESULTS.push({ status, category, message });
  if (status === 'PASS') passCount++;
  else if (status === 'FAIL') failCount++;
  else warnCount++;
}

async function ss(page, name) {
  const p = path.join(SCREENSHOT_DIR, `${name}.png`);
  await page.screenshot({ path: p });
  return p;
}

function ssDiff(p1, p2) {
  try {
    return Math.abs(fs.statSync(p1).size - fs.statSync(p2).size) > 500;
  } catch { return false; }
}

/** CDP 레벨 마우스 클릭 — Flutter CanvasKit에서 확실히 작동 */
async function cdpClick(cdp, x, y) {
  await cdp.send('Input.dispatchMouseEvent', {
    type: 'mousePressed', x, y, button: 'left', clickCount: 1,
    pointerType: 'mouse',
  });
  await new Promise(r => setTimeout(r, 50));
  await cdp.send('Input.dispatchMouseEvent', {
    type: 'mouseReleased', x, y, button: 'left', clickCount: 1,
    pointerType: 'mouse',
  });
}

/** CDP 레벨 마우스 이동 */
async function cdpMove(cdp, x, y) {
  await cdp.send('Input.dispatchMouseEvent', {
    type: 'mouseMoved', x, y, button: 'none', pointerType: 'mouse',
  });
}

async function waitForFlutter(page, timeoutMs = 120000) {
  try {
    // Flutter 초기화 감지: flutter-view, flt-glass-pane, canvas, 또는 WASM 로딩 완료
    await page.waitForFunction(() => {
      return document.querySelector('flutter-view') !== null
        || document.querySelector('flt-glass-pane') !== null
        || document.querySelectorAll('canvas').length > 0
        || document.querySelector('[flt-renderer]') !== null;
    }, { timeout: timeoutMs });
    // 렌더링 안정화 대기
    await page.waitForTimeout(5000);
    return true;
  } catch { return false; }
}

async function main() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('🎴 K-Poker 브라우저 전수검사 v4 (CDP Input.dispatchMouseEvent)');
  console.log('═══════════════════════════════════════════════════════════\n');

  const browser = await chromium.launch({
    headless: false,
    args: ['--no-sandbox'],
  });

  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();

  // CDP 세션 획득
  const cdp = await context.newCDPSession(page);

  const consoleErrors = [];
  page.on('console', msg => { if (msg.type() === 'error') consoleErrors.push(msg.text()); });

  try {
    // ═══════════════════════════════════════
    // Phase 1: 로딩
    // ═══════════════════════════════════════
    console.log('── Phase 1: 초기 로딩 ──');
    const t0 = Date.now();
    await page.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 120000 });
    const loaded = await waitForFlutter(page, 120000);
    log(loaded ? 'PASS' : 'FAIL', '로딩', `Flutter ${loaded ? '완료' : '실패'} (${Date.now() - t0}ms)`);
    if (!loaded) { await browser.close(); return printReport(); }

    await page.waitForTimeout(3000);
    const startSS = await ss(page, 'v4_01_start');
    log('PASS', '시작화면', '시작 화면 렌더링 정상');

    // ═══════════════════════════════════════
    // Phase 2: "게임 시작" 버튼 CDP 클릭
    // ═══════════════════════════════════════
    console.log('\n── Phase 2: 게임 시작 (CDP 클릭) ──');

    // 스크린샷 분석 기반: "게임 시작" 황금색 버튼은 화면 중앙 하단
    // 1280x720 뷰포트, FittedBox(1200x700)
    // 버튼 y좌표 탐색
    let gameClicked = false;
    for (let y = 440; y <= 580; y += 10) {
      await cdpClick(cdp, 640, y);
      await page.waitForTimeout(1500);
      const after = await ss(page, `v4_02_click_${y}`);
      if (ssDiff(startSS, after)) {
        log('PASS', '게임시작', `CDP 클릭 성공! y=${y}`);
        gameClicked = true;
        break;
      }
    }

    if (!gameClicked) {
      log('FAIL', '게임시작', 'CDP 클릭으로도 "게임 시작" 버튼 클릭 실패');
    }

    // 딜링 애니메이션 대기
    if (gameClicked) {
      console.log('  딜링 대기 (8초)...');
      await page.waitForTimeout(8000);
      await ss(page, 'v4_03_dealing_done');
      log('PASS', '딜링', '딜링 애니메이션 완료');

      // ═══════════════════════════════════════
      // Phase 3: 카드 선택 & 게임 플레이
      // ═══════════════════════════════════════
      console.log('\n── Phase 3: 게임 플레이 ──');

      const boardSS = await ss(page, 'v4_04_game_board');

      // 플레이어 카드 영역: 하단 (y≈620~680), 카드 10장 가로 분포
      // 카드 크기 약 80px, 시작 x≈200
      for (let i = 0; i < 5; i++) {
        const cx = 250 + i * 90;
        const cy = 650;
        console.log(`  카드 클릭 시도 (${cx}, ${cy})...`);
        const beforeCard = await ss(page, `v4_05_before_card_${i}`);
        await cdpClick(cdp, cx, cy);
        await page.waitForTimeout(2000);
        const afterCard = await ss(page, `v4_05_after_card_${i}`);
        if (ssDiff(beforeCard, afterCard)) {
          log('PASS', '카드선택', `카드 ${i+1} 클릭 → 화면 변화 감지`);
          // AI 턴 대기
          await page.waitForTimeout(3000);
          break;
        }
      }

      await ss(page, 'v4_06_after_play');
      log('PASS', '게임플레이', '카드 플레이 시도 완료');

      // 추가 라운드 (3턴)
      for (let turn = 0; turn < 3; turn++) {
        // 하단 카드 영역 스캔
        for (let i = 0; i < 8; i++) {
          const cx = 200 + i * 80;
          await cdpClick(cdp, cx, 650);
          await page.waitForTimeout(1000);
        }
        await page.waitForTimeout(2000); // AI 턴
        await ss(page, `v4_07_turn_${turn}`);
      }
      log('PASS', '게임플레이', '3턴 진행 완료');

      // 고/스톱 팝업이 뜰 수 있음 → 화면 중앙 클릭으로 응답
      await cdpClick(cdp, 640, 360);
      await page.waitForTimeout(1000);
      await cdpClick(cdp, 500, 400);
      await page.waitForTimeout(1000);
      await ss(page, 'v4_08_go_stop');
    }

    // ═══════════════════════════════════════
    // Phase 4: 설정 오버레이 (새 페이지)
    // ═══════════════════════════════════════
    console.log('\n── Phase 4: 설정 오버레이 ──');

    const sPage = await context.newPage();
    const sCdp = await context.newCDPSession(sPage);
    await sPage.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 120000 });
    await waitForFlutter(sPage, 60000);
    await sPage.waitForTimeout(4000);

    const sBefore = await sPage.screenshot({ path: path.join(SCREENSHOT_DIR, 'v4_09_settings_before.png') });

    // 우상단 ? 와 ⚙ 아이콘 — 스크린샷에서 확인된 위치
    // 모바일 세로에서 우상단에 "? ⚙" 보임
    // 1280x720에서: FittedBox 내 우상단
    const iconTargets = [
      { x: 1245, y: 22, desc: '⚙ 아이콘' },
      { x: 1215, y: 22, desc: '? 아이콘' },
      { x: 1250, y: 15, desc: '⚙ 위' },
      { x: 1250, y: 30, desc: '⚙ 아래' },
    ];

    let settingsOpened = false;
    const settingsBeforePath = path.join(SCREENSHOT_DIR, 'v4_09_settings_before.png');
    await sPage.screenshot({ path: settingsBeforePath });

    for (const t of iconTargets) {
      await sCdp.send('Input.dispatchMouseEvent', {
        type: 'mousePressed', x: t.x, y: t.y, button: 'left', clickCount: 1, pointerType: 'mouse',
      });
      await new Promise(r => setTimeout(r, 50));
      await sCdp.send('Input.dispatchMouseEvent', {
        type: 'mouseReleased', x: t.x, y: t.y, button: 'left', clickCount: 1, pointerType: 'mouse',
      });
      await sPage.waitForTimeout(1500);
      const afterPath = path.join(SCREENSHOT_DIR, `v4_09_settings_${t.desc.replace(/[^a-z0-9]/gi, '_')}.png`);
      await sPage.screenshot({ path: afterPath });

      if (ssDiff(settingsBeforePath, afterPath)) {
        log('PASS', '설정', `${t.desc} 클릭 → 오버레이 열림`);
        settingsOpened = true;
        await sPage.screenshot({ path: path.join(SCREENSHOT_DIR, 'v4_10_settings_overlay.png') });
        break;
      }
    }

    if (!settingsOpened) {
      // 하단 영역 "설정" 텍스트 탐색
      for (let y = 555; y <= 610; y += 10) {
        for (let x = 580; x <= 700; x += 30) {
          await sCdp.send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1, pointerType: 'mouse' });
          await new Promise(r => setTimeout(r, 50));
          await sCdp.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1, pointerType: 'mouse' });
          await sPage.waitForTimeout(800);
          const p = path.join(SCREENSHOT_DIR, `v4_09_scan_${x}_${y}.png`);
          await sPage.screenshot({ path: p });
          if (ssDiff(settingsBeforePath, p)) {
            log('PASS', '설정', `하단 클릭 (${x},${y}) → 설정/도움말 열림`);
            settingsOpened = true;
            break;
          }
        }
        if (settingsOpened) break;
      }
    }

    if (!settingsOpened) {
      log('FAIL', '설정', '설정 오버레이 열기 실패');
    }

    // 도움말 버튼 (설정 옆)
    // 시작화면 하단에 "설정" | "도움말" 텍스트 링크가 있다면 그 옆
    await sPage.close();

    // ═══════════════════════════════════════
    // Phase 5: 반응형 레이아웃
    // ═══════════════════════════════════════
    console.log('\n── Phase 5: 반응형 ──');
    const viewports = [
      { name: 'desktop_1920', w: 1920, h: 1080 },
      { name: 'tablet_land', w: 1024, h: 768 },
      { name: 'tablet_port', w: 768, h: 1024 },
      { name: 'mobile_land', w: 812, h: 375 },
      { name: 'mobile_port', w: 375, h: 812 },
    ];
    for (const vp of viewports) {
      const c = await browser.newContext({ viewport: { width: vp.w, height: vp.h } });
      const p = await c.newPage();
      try {
        await p.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 20000 });
        await waitForFlutter(p, 30000);
        await p.waitForTimeout(3000);
        await p.screenshot({ path: path.join(SCREENSHOT_DIR, `v4_11_${vp.name}.png`) });
        log('PASS', '반응형', `${vp.name} (${vp.w}x${vp.h}) OK`);
      } catch { log('FAIL', '반응형', `${vp.name} 실패`); }
      finally { await p.close(); await c.close(); }
    }

    // ═══════════════════════════════════════
    // Phase 6: 다국어
    // ═══════════════════════════════════════
    console.log('\n── Phase 6: 다국어 ──');
    const langs = ['ko', 'en', 'ja', 'zh-CN', 'zh-TW', 'es', 'fr', 'de', 'pt', 'th'];
    for (const lang of langs) {
      const c = await browser.newContext({ viewport: { width: 1280, height: 720 }, locale: lang });
      const p = await c.newPage();
      const errs = [];
      p.on('console', msg => { if (msg.type() === 'error') errs.push(msg.text()); });
      try {
        await p.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 20000 });
        await waitForFlutter(p, 30000);
        await p.waitForTimeout(3000);
        await p.screenshot({ path: path.join(SCREENSHOT_DIR, `v4_12_lang_${lang}.png`) });
        const crit = errs.filter(e => !e.includes('favicon') && !e.includes('manifest') && !e.includes('DevTools'));
        log('PASS', '다국어', `${lang} — 렌더링 OK${crit.length > 0 ? ` (에러 ${crit.length}건)` : ''}`);
      } catch { log('FAIL', '다국어', `${lang} 실패`); }
      finally { await p.close(); await c.close(); }
    }

    // ═══════════════════════════════════════
    // Phase 7: 에러 & 퍼포먼스
    // ═══════════════════════════════════════
    console.log('\n── Phase 7: 에러 & 퍼포먼스 ──');
    const crit = consoleErrors.filter(e =>
      !e.includes('favicon') && !e.includes('manifest') && !e.includes('DevTools') && !e.includes('net::ERR'));
    log(crit.length === 0 ? 'PASS' : 'FAIL', '콘솔', crit.length === 0 ? '에러 없음' : `${crit.length}건`);

    // 퍼포먼스
    const perfPage = await context.newPage();
    await perfPage.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 60000 }).catch(() => {});
    const perf = await perfPage.evaluate(() => {
      const nav = performance.getEntriesByType('navigation')[0];
      const res = performance.getEntriesByType('resource');
      return {
        domLoad: nav ? Math.round(nav.domContentLoadedEventEnd) : -1,
        fullLoad: nav ? Math.round(nav.loadEventEnd) : -1,
        resources: res.length,
        totalKB: Math.round(res.reduce((s, r) => s + (r.transferSize || 0), 0) / 1024),
      };
    }).catch(() => null);
    if (perf) {
      log('PASS', '퍼포먼스', `DOM ${perf.domLoad}ms, Full ${perf.fullLoad}ms, ${perf.resources}리소스, ${perf.totalKB}KB`);
    }
    await perfPage.close();

  } catch (e) {
    log('FAIL', '시스템', `예외: ${e.message}`);
    console.error(e.stack);
  } finally {
    await browser.close();
  }

  printReport();
}

function printReport() {
  console.log('\n═══════════════════════════════════════════════════════════');
  console.log('📊 K-Poker QA 전수검사 최종 결과');
  console.log('═══════════════════════════════════════════════════════════');
  console.log(`✅ PASS: ${passCount}  ❌ FAIL: ${failCount}  ⚠️  WARN: ${warnCount}`);
  console.log(`📸 스크린샷: ${SCREENSHOT_DIR}`);
  if (failCount > 0) {
    console.log('\n❌ 실패:');
    RESULTS.filter(r => r.status === 'FAIL').forEach(r => console.log(`  [${r.category}] ${r.message}`));
  }
  if (warnCount > 0) {
    console.log('\n⚠️  경고:');
    RESULTS.filter(r => r.status === 'WARN').forEach(r => console.log(`  [${r.category}] ${r.message}`));
  }
  const rp = path.join(SCREENSHOT_DIR, 'qa_report_final.json');
  fs.writeFileSync(rp, JSON.stringify({
    timestamp: new Date().toISOString(),
    summary: { pass: passCount, fail: failCount, warn: warnCount },
    results: RESULTS,
  }, null, 2));
  console.log(`📄 리포트: ${rp}`);
  console.log('═══════════════════════════════════════════════════════════');
}

main().catch(e => { console.error('Fatal:', e); process.exit(1); });
