'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { chromium } = require('playwright');

test('bundled offline article fits reading widths and responds to the actual engine', async () => {
  const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH || undefined });
  const output = path.join(__dirname, '..', 'test-results');
  fs.mkdirSync(output, { recursive: true });
  try {
    for (const width of [390, 768, 1280, 1440]) {
      for (const colorScheme of ['light', 'dark']) {
        const page = await browser.newPage({ viewport: { width, height: 844 }, colorScheme, reducedMotion: 'reduce' });
        await page.context().setOffline(true);
        await page.goto(pathToFileURL(path.join(__dirname, '..', 'iOS', 'Resources', 'demo.html')).href);
        await page.addScriptTag({ path: path.join(__dirname, '..', 'iOS', 'Resources', 'scroll-controller.js') });
        const before = await page.evaluate(() => ({
          width: document.documentElement.scrollWidth,
          viewport: innerWidth,
          headings: document.querySelectorAll('h1').length,
        }));
        assert.equal(before.headings, 1);
        assert.ok(before.width <= before.viewport, `${width}/${colorScheme}: horizontal overflow`);
        await page.screenshot({ path: path.join(output, `sample-${width}-${colorScheme}.png`), fullPage: false });
        const after = await page.evaluate(() => {
          wristScroll({ kind: 'page', amount: 1 });
          return { offset: document.scrollingElement.scrollTop, viewport: document.scrollingElement.clientHeight };
        });
        assert.ok(Math.abs(after.offset - after.viewport * 0.85) <= 1);
        await page.close();
      }
    }
  } finally { await browser.close(); }
});
