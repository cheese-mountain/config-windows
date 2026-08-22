# Baseline checks

The rules that hold whatever the spec says. Run the sections matching the surface you reviewed; mark the rest `n/a` in the report.

## Always

**Console** — `playwright-cli -s=designer console` after walking the flow. Errors are Blockers, warnings are Medium. React key warnings and hydration mismatches count.

**Keyboard** — tab from the top of the page through every interactive element in the change. Each stop must be visible on screen, carry a focus ring you can see in a screenshot, and activate with Enter or Space. Focus that jumps out of document order, lands on nothing, or disappears inside a modal is a Blocker.

**Semantics** — a clickable `div` is a Blocker; buttons are `<button>`, links are `<a href>`. Headings descend without skipping a level. Landmark regions (`main`, `nav`, `header`) exist once each.

**Contrast** — 4.5:1 for body text, 3:1 for text at 24px or 19px-bold and above, and for the boundary of interactive elements. Compute rather than judge:

```js
() => {
  const lum = (c) => {
    const [r, g, b] = c.match(/\d+/g).map((v) => {
      const n = v / 255;
      return n <= 0.03928 ? n / 12.92 : ((n + 0.055) / 1.055) ** 2.4;
    });
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  };
  return [...document.querySelectorAll('p,span,a,button,label,li,h1,h2,h3')]
    .filter((el) => el.textContent.trim())
    .map((el) => {
      const s = getComputedStyle(el);
      let bgEl = el;
      let bg = s.backgroundColor;
      while (bg === 'rgba(0, 0, 0, 0)' && bgEl.parentElement) {
        bgEl = bgEl.parentElement;
        bg = getComputedStyle(bgEl).backgroundColor;
      }
      const [a, b] = [lum(s.color), lum(bg)].sort((x, y) => y - x);
      return {
        text: el.textContent.trim().slice(0, 30),
        size: s.fontSize,
        ratio: +((a + 0.05) / (b + 0.05)).toFixed(2),
      };
    })
    .filter((r) => r.ratio < 4.5);
};
```

**Images** — every `<img>` carries `alt`; decorative images carry `alt=""`. Missing `alt` is High.

**Motion** — anything that animates respects `prefers-reduced-motion`. Emulate it and re-render.

## Forms

Every input has a `<label>` bound by `for`/`id`, or an `aria-label`. Submit the form empty, then with each field invalid in turn: the error must name the field, sit next to it, and reach a screen reader through `aria-describedby` or `role="alert"`. Confirm focus moves to the first invalid field. Required fields carry `required`, not only a visual asterisk.

## Lists and data

Render the empty state, the single-row state, and an overflowing state. Paste 200 characters into any field that renders back into the layout, and check the container grows or truncates rather than spilling. Loading states occupy the space their content will occupy — layout that jumps on load is Medium.

## Destructive actions

Delete, archive, and bulk operations confirm before firing, name the specific object in the confirmation, and offer a way back. A destructive action that fires on a single click is a Blocker. Screenshot the confirmation without completing the action.

## Media and embeds

Video and audio expose native controls, do not autoplay with sound, and carry captions where the spec calls for them. Iframes carry a `title`.
