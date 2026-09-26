'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

const controller = fs.readFileSync(
  path.join(__dirname, '..', 'iOS', 'Resources', 'scroll-controller.js'),
  'utf8',
);
const executablePath = process.env.CHROME_PATH || undefined;
let browser;

test.before(async () => {
  browser = await chromium.launch({ headless: true, executablePath });
});

test.after(async () => {
  if (browser) await browser.close();
});

async function pageWith(body, viewport = { width: 800, height: 600 }) {
  const page = await browser.newPage({ viewport });
  await page.setContent(`<!doctype html><style>
    html, body { margin: 0; padding: 0; }
    #content { height: 3000px; background: linear-gradient(#fff, #ddd); }
  </style>${body}`);
  await page.addScriptTag({ content: controller });
  return page;
}

test('scroll commands move down and up by viewport fractions', async () => {
  const page = await pageWith('<div id="content"></div>');
  const values = await page.evaluate(() => {
    const down = wristScroll({ kind: 'scroll', amount: 0.5 });
    const up = wristScroll({ kind: 'scroll', amount: -0.5 });
    return { down, up, offset: document.scrollingElement.scrollTop };
  });
  assert.equal(values.down.ok, true);
  assert.equal(values.down.moved, true);
  assert.equal(values.up.moved, true);
  assert.equal(values.offset, 0);
  await page.close();
});

test('page commands move 0.85 viewport and clamp at both bounds', async () => {
  const page = await pageWith('<div id="content"></div>');
  const values = await page.evaluate(() => {
    const first = wristScroll({ kind: 'page', amount: 1 });
    const second = wristScroll({ kind: 'page', amount: 1 });
    const maximum = document.scrollingElement.scrollHeight - document.scrollingElement.clientHeight;
    document.scrollingElement.scrollTop = maximum - 100;
    const toBottom = wristScroll({ kind: 'page', amount: 1 });
    const atBottom = wristScroll({ kind: 'page', amount: 1 });
    const up = wristScroll({ kind: 'page', amount: -1 });
    return { first, second, toBottom, atBottom, up, maximum, offset: document.scrollingElement.scrollTop };
  });
  assert.equal(values.first.moved, true);
  assert.ok(Math.abs(values.first.position - 0.85 * 600 / values.maximum) < 0.01);
  assert.equal(values.toBottom.moved, true);
  assert.equal(values.atBottom.position, 1);
  assert.equal(values.atBottom.moved, false);
  assert.equal(values.up.moved, true);
  assert.equal(values.offset, values.maximum - 0.85 * 600);
  await page.close();
});

test('empty pages and invalid or nonfinite amounts do not scroll', async () => {
  const page = await pageWith('<div style="height: 10px"></div>');
  const empty = await page.evaluate(() => wristScroll({ kind: 'page', amount: 1 }));
  assert.equal(empty.ok, true);
  assert.equal(empty.moved, false);
  assert.equal(empty.position, 0);
  const values = await page.evaluate(() => [
    wristScroll({ kind: 'scroll', amount: 2 }),
    wristScroll({ kind: 'scroll', amount: NaN }),
    wristScroll({ kind: 'scroll', amount: Infinity }),
    wristScroll({ kind: 'page', amount: 0 }),
    wristScroll({ kind: 'unknown', amount: 1 }),
    wristScroll(null),
  ]);
  for (const value of values) {
    assert.equal(value.ok, false, JSON.stringify(value));
    assert.equal(value.moved, false, JSON.stringify(value));
    assert.equal(value.position, 0, JSON.stringify(value));
  }
  await page.close();
});

test('page CSS smooth scrolling cannot delay a command beyond its reply', async () => {
  const page = await pageWith('<style>html { scroll-behavior: smooth; }</style><div id="content"></div>');
  await page.emulateMedia({ reducedMotion: 'reduce' });
  const values = await page.evaluate(() => {
    const response = wristScroll({ kind: 'page', amount: 1 });
    return { response, offset: document.scrollingElement.scrollTop };
  });
  assert.equal(values.response.moved, true);
  assert.equal(values.offset, 510);
  await page.waitForTimeout(100);
  assert.equal(await page.evaluate(() => document.scrollingElement.scrollTop), 510);
  await page.close();
});

test('focused nested panel receives scrolling', async () => {
  const page = await pageWith('<div id="panel" tabindex="0" style="height: 180px; overflow-y: auto;"><div style="height: 1000px"></div></div>');
  const values = await page.evaluate(() => {
    const panel = document.querySelector('#panel');
    panel.focus();
    const response = wristScroll({ kind: 'scroll', amount: 1 });
    return { response, panel: panel.scrollTop, document: document.scrollingElement.scrollTop };
  });
  assert.equal(values.response.moved, true);
  assert.ok(values.panel > 0);
  assert.equal(values.document, 0);
  await page.close();
});

test('last pointer target selects nested panel and detached target falls back safely', async () => {
  const page = await pageWith('<div id="panel" style="height: 180px; overflow-y: auto;"><button id="inside">inside</button><div style="height: 1000px"></div></div><div id="content"></div>');
  const values = await page.evaluate(() => {
    const panel = document.querySelector('#panel');
    const inside = document.querySelector('#inside');
    inside.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));
    const nested = wristScroll({ kind: 'scroll', amount: 1 });
    panel.remove();
    const documentBefore = document.scrollingElement.scrollTop;
    const fallback = wristScroll({ kind: 'scroll', amount: 1 });
    return { nested, fallback, panelOffset: nested.position, documentBefore, documentAfter: document.scrollingElement.scrollTop };
  });
  assert.equal(values.nested.moved, true);
  assert.equal(values.documentBefore, 0);
  assert.equal(values.fallback.moved, true);
  assert.ok(values.documentAfter > values.documentBefore);
  await page.close();
});
