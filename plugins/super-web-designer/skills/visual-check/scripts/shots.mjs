#!/usr/bin/env node
// visual-check: desktop + mobile screenshots, exit 1 on non-2xx / JS error / mobile h-scroll.
//   node shots.mjs [--base URL] [--out DIR] [--motion] <route|url>...
import { createRequire } from 'node:module';
import { execSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

const args = process.argv.slice(2);
const opt = (name, def) => { const i = args.indexOf(name); return i >= 0 ? args.splice(i, 2)[1] : def; };
const flag = (name) => { const i = args.indexOf(name); return i >= 0 ? (args.splice(i, 1), true) : false; };
const BASE = opt('--base', process.env.BASE_URL || 'http://127.0.0.1:4321').replace(/\/$/, '');
const OUT = opt('--out', 'shots');
const motion = flag('--motion');
const targets = args.length ? args : ['/'];

function loadPlaywright() {
  const cache = join(homedir(), '.cache', 'visual-check');
  const tryFrom = (dir) => {
    const req = createRequire(join(dir, 'noop.js'));
    for (const pkg of ['playwright', 'playwright-core']) { try { return req(pkg); } catch {} }
    return null;
  };
  let pw = tryFrom(process.cwd()) || tryFrom(cache);
  if (pw) return pw;
  console.error('visual-check: installing playwright-core into ' + cache + ' (once)…');
  mkdirSync(cache, { recursive: true });
  execSync(`npm install --prefix "${cache}" playwright-core --no-audit --no-fund --silent`, {
    stdio: 'inherit', env: { ...process.env, PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD: '1' },
  });
  return tryFrom(cache);
}

function sandboxChromium() {
  const root = process.env.PLAYWRIGHT_BROWSERS_PATH || '/opt/pw-browsers';
  if (!existsSync(root)) return null;
  const dirs = readdirSync(root).filter((d) => /^chromium-\d+$/.test(d)).sort().reverse();
  for (const d of dirs) {
    const p = join(root, d, 'chrome-linux', 'chrome');
    if (existsSync(p)) return p;
  }
  return null;
}

const { chromium } = loadPlaywright();
const exe = sandboxChromium();
let browser;
try { browser = await chromium.launch(exe ? { executablePath: exe } : {}); }
catch { browser = await chromium.launch({ channel: 'chrome' }); }

const viewports = {
  desktop: { viewport: { width: 1440, height: 900 } },
  mobile: { viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true, deviceScaleFactor: 2 },
};

mkdirSync(OUT, { recursive: true });
let failed = 0;
for (const t of targets) {
  const url = /^https?:\/\//.test(t) ? t : BASE + (t.startsWith('/') ? t : '/' + t);
  const slug = new URL(url).pathname.replace(/^\/|\/$/g, '').replace(/[^\w-]+/g, '_') || 'home';
  for (const [name, vp] of Object.entries(viewports)) {
    const ctx = await browser.newContext({ ...vp, reducedMotion: motion ? 'no-preference' : 'reduce' });
    const page = await ctx.newPage();
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));
    let status = 'no response';
    try {
      const res = await page.goto(url, { waitUntil: 'networkidle', timeout: 45000 });
      status = res ? res.status() : status;
      await page.evaluate(() => document.fonts && document.fonts.ready);
    } catch (e) { errors.push(String(e.message || e).split('\n')[0]); }
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth).catch(() => 0);
    const file = join(OUT, `${slug}-${name}.png`);
    await page.screenshot({ path: file, fullPage: true }).catch((e) => errors.push('screenshot: ' + e.message));
    const bad = !(status >= 200 && status < 300) || overflow > 0 || errors.length;
    if (bad) failed++;
    const notes = [status, overflow > 0 ? `HORIZONTAL SCROLL +${overflow}px` : null, ...errors.map((e) => 'JS: ' + e)];
    console.log(`${bad ? '✗' : '✓'} ${file}  ${notes.filter(Boolean).join(' · ')}`);
    await ctx.close();
  }
}
await browser.close();
process.exit(failed ? 1 : 0);
