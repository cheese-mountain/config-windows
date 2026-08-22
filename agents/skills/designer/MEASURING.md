# Measuring a page

Invoke the `playwright-cli` skill for the command surface — opening, navigating, clicking, snapshots, sessions, auth, and the Windows `&` escaping rule all live there. This file covers only what designer adds on top: pulling numbers out of a rendered page and not being fooled by them.

Run under a named session so designer's browser stays clear of other work:

```bash
playwright-cli -s=designer open http://localhost:3000
playwright-cli -s=designer resize 1440 900
```

## The measure loop

Per viewport: resize, screenshot, extract, check the console.

```bash
for w in 1440 768 375; do
  playwright-cli -s=designer resize $w 900
  playwright-cli -s=designer screenshot --filename=shot-$w.png
  playwright-cli -s=designer --raw run-code --filename=measure.js > measure-$w.json
done
playwright-cli -s=designer console
```

Keep the JSON. After fixing, re-run the same loop and diff — that diff is what proves a fix and catches the fix that broke a neighbour.

## Extractors

Write these to a file and run with `--raw run-code --filename=<file>`.

**`run-code` files must be a bare expression with no trailing semicolon.** A trailing `;` fails with `SyntaxError: Unexpected token ';'` because the contents are wrapped as an expression.

**Tally a property across the page** — the workhorse. The long tail is where violations hide: a value used twice among forty is almost always a mistake.

```js
async (page) =>
  await page.evaluate(() => {
    const tally = (fn, sel = '*', n = 12) => {
      const counts = {};
      for (const el of document.querySelectorAll(sel)) {
        if (!el.getClientRects().length) continue;
        const v = fn(getComputedStyle(el), el);
        if (!v || v === '0px' || v === 'none' || v === 'normal' || v === 'rgba(0, 0, 0, 0)') continue;
        counts[v] = (counts[v] ?? 0) + 1;
      }
      return Object.entries(counts)
        .sort((a, b) => b[1] - a[1])
        .slice(0, n)
        .map(([v, c]) => `${v} x${c}`);
    };
    const t = 'h1,h2,h3,h4,h5,h6,p,span,a,button,label,li,td,th';
    return {
      overflow: document.documentElement.scrollWidth > document.documentElement.clientWidth,
      fontFamilies: tally((s) => s.fontFamily, t, 6),
      fontSizes: tally((s) => s.fontSize, t),
      fontWeights: tally((s) => s.fontWeight, t, 6),
      textColors: tally((s) => s.color, t),
      bgColors: tally((s) => s.backgroundColor, '*', 14),
      radius: tally((s) => s.borderRadius, '*', 10),
      borderColors: tally((s) => (s.borderTopWidth !== '0px' ? s.borderTopColor : null), '*', 8),
      shadows: tally((s) => s.boxShadow, '*', 8),
      gaps: tally((s) => s.gap, '*', 10),
    };
  })
```

**Component specs** — for rules about a named component:

```js
async (page) =>
  await page.evaluate(() =>
    [...document.querySelectorAll('button')]
      .filter((el) => el.getClientRects().length && el.innerText.trim())
      .map((el) => {
        const s = getComputedStyle(el);
        return {
          text: el.innerText.trim().slice(0, 22),
          bg: s.backgroundColor,
          color: s.color,
          border: s.borderTopWidth === '0px' ? 'none' : `${s.borderTopWidth} ${s.borderTopColor}`,
          radius: s.borderRadius,
          pad: s.padding,
          fs: s.fontSize,
          fw: s.fontWeight,
          h: Math.round(el.getBoundingClientRect().height),
        };
      }),
  )
```

**Resolve a token** — short enough for a one-liner:

```bash
playwright-cli -s=designer --raw eval "JSON.stringify(getComputedStyle(document.documentElement).getPropertyValue('--primary'))"
```

A declared token proves nothing on its own. Check that a rendered element resolves to it before treating the token layer as the spec — a `:root` block the app never renders through is decoration.

**Convert `oklch` to hex** for a readable report, by rasterising through a canvas:

```bash
playwright-cli -s=designer --raw eval "(() => { const c = document.createElement('canvas').getContext('2d'); c.fillStyle = 'oklch(0.373 0.034 259.733)'; c.fillRect(0,0,1,1); const [r,g,b] = c.getImageData(0,0,1,1).data; return '#' + [r,g,b].map(v => v.toString(16).padStart(2,'0')).join('').toUpperCase(); })()"
```

**Overlap and alignment** — `snapshot --boxes` prints each element's `[box=x,y,width,height]`, which turns "do these overlap" and "are these aligned" into arithmetic instead of judgement:

```bash
playwright-cli -s=designer snapshot --boxes --filename=boxes-375.yml
```

## Two traps that manufacture false findings

- **Border widths come back snapped to device pixels.** On a 1.5x display an authored `1px` reports as `0.666667px`. Multiply by `devicePixelRatio` before calling it a violation.
- **Fractional font sizes are usually authored.** `text-[13.5px]` is a real choice, not a rendering artefact.

When a value looks wrong, settle it with a probe before reporting — append an element with the value you expect and read its computed style back:

```js
async (page) =>
  await page.evaluate(() => {
    const el = document.createElement('div');
    el.style.cssText = 'font-size:14px;border-top:1px solid red;position:fixed;top:-999px';
    document.body.appendChild(el);
    const s = getComputedStyle(el);
    const out = { fontSize: s.fontSize, border: s.borderTopWidth, dpr: devicePixelRatio };
    el.remove();
    return out;
  })
```

A probe that reports back what you set means the page measures true and the odd value is real.

## Pages behind a login

A fresh browser has no session and lands on the login page. Two ways through, both of which leave credentials with the user:

```bash
playwright-cli -s=designer attach --cdp=chrome        # drive the user's already-signed-in Chrome
playwright-cli -s=designer state-save auth.json       # after the user signs in, reuse with state-load
```

Ask the user to sign in themselves — never type credentials.

## Asking the user what they think

`show --annotate` opens the page for the user to draw on and comment; you get back the annotated screenshot, the snapshot of the marked region, and their notes.

```bash
playwright-cli -s=designer show --annotate
```

Reach for it when the question is taste rather than spec — a Nit worth raising, a rule the measurements cannot settle, or a build where the spec left the look open. Findings that a measurement already decides do not need it.

To point at a specific element while discussing it:

```bash
playwright-cli -s=designer highlight e15 --style="outline: 3px dashed red"
playwright-cli -s=designer highlight --hide
```
