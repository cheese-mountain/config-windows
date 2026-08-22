# House style — Tsenta

The default spec when no style guide was supplied. Extracted from `https://dashboard.tsenta.com/dashboard` (authenticated, 1440px, light mode) — measured computed values, not the source.

Stack is shadcn/ui on Tailwind v4. Treat the rules below as the numbered spec for step 1 and give each one a verdict.

## The look in one line

A dense, quiet, light-grey admin surface: white cards on `#F9FAFB`, hairline grey borders, near-flat shadows, pill-shaped controls, small type at weight 500, and a single deep-green accent that appears only where something is active or primary.

## 1. Typography

1. **One family, everywhere** — `"Century Gothic", "Helvetica Neue", Helvetica, -apple-system, BlinkMacSystemFont, system-ui, sans-serif`. The reference renders 130 of 130 text elements in it. A second family on a screen is a violation.
2. **Small by default.** The scale is `11 / 12 / 13 / 16px`, with 12px the most common and 16px reserved for lead paragraphs and large CTA labels. Body copy at 14–16px reads oversized against this app.
3. **Weight 500 is the default**, not 400. Weight ramp: `500` (most UI text) → `400` (prose and long descriptions) → `600` (headings, emphasis). Weight 700 does not appear.
4. **Line height sits tight**, ~1.35–1.5× — `16px/12px`, `16.5px/12px`, `19.5px/13px`, `24px/16px`.
5. Letter spacing is `normal` except on large display text, which tightens slightly negative.

Half-pixel sizes (`text-[10.5px]`, `text-[12.5px]`, `text-[13.5px]`) are authored deliberately in the reference and are in-style — they are not a rendering artefact.

## 2. Colour

**Brand.** `#15362B` deep green — the `--primary` token. It appears only on primary buttons and active/selected chips. Green on a passive surface is a violation.

**Surfaces.**

| Role | Value |
| --- | --- |
| Page background | `#F9FAFB` |
| Card / panel | `#FFFFFF` |
| Sidebar | `#FAFAFA` |
| Warm cream (marketing surfaces) | `#FAF9F5` |
| Amber tint (warning/notice) | `#FFEDD4` |

**Text ramp** — four steps, used in this order of frequency:

| Role | Value |
| --- | --- |
| Primary | `#101828` |
| Body (most used) | `#364153` |
| Secondary | `#4A5565` |
| Tertiary | `#6A7282` |
| Disabled / placeholder | `#99A1AF` |

**Borders.** `#E5E7EB` is the workhorse (26 of 32 bordered elements); `#F3F4F6` for the subtlest dividers. Always `1px`.

6. Text uses one of the five ramp values. A grey outside the ramp is a violation.
7. Borders are `1px` in `#E5E7EB` or `#F3F4F6`.
8. `#15362B` appears only on primary actions and active state.

## 3. Radius

9. **Pill (`9999px`) is the dominant shape** — 39 of 83 rounded elements. Filter chips, tags, badges, search fields, and the send button are all fully rounded.
10. **Cards use `14px`**; larger grouped containers use `18px`.
11. Small inline controls use `10px`; the smallest affordances use `4px`.

The `--radius` token is `0.625rem` (10px), but the rendered app overrides it far more often than it uses it. Follow the rendered values above.

## 4. Spacing and density

12. Flex gaps come from `4 / 6 / 8 / 12px`, with **6px the most common** — this app is deliberately tight. A 16px+ gap between sibling controls reads foreign.
13. Card padding is `12px`, `14px 16px`, or `6px` for chip-group containers.
14. Control heights: chips `24–25px`, icon/text buttons `28px`, the send control `32px`, large CTA cards `52px`.

## 5. Elevation

15. Shadows are near-invisible. The two in use are `0 1px 2px rgba(0,0,0,.04)` and `0 1px 3px rgba(0,0,0,.1)`. Modals go to `0 18px 44px rgba(20,20,19,.1)`. Anything heavier than these is a violation.

## 6. Components

**Primary button** — `#15362B` background, white text, pill radius, `12px/500`, `4px 10px` padding, ~24px tall.

**Secondary / filter chip** — white background, `1px #E5E7EB` border, `#4A5565` text, pill radius, `12px/500`, `4px 10px` padding, ~25px tall. Selected state swaps to the primary treatment and appends a count.

**Ghost button** — transparent background, no border, `#0F0C08EB` text, `13px/450`, `4px 6px` padding, `4px` radius.

**Large suggestion card** — white, `1px rgba(15,12,8,.1)` border, `26px` radius, `16px/400`, `10px 16px 10px 10px` padding, `52px` tall.

**Card** — white, `1px #E5E7EB`, `14px` radius, `14px 16px` padding, one of the two hairline shadows.

**Text input** — mostly borderless and transparent, sitting inside a bordered container rather than carrying its own chrome. The one self-contained input is pill-shaped, white, `1px #E5E7EB`, `12px`, 28px tall.

## Known gaps in the reference

Carry these forward as deliberate absences, not as licence:

- **Dark mode is not implemented.** The `.dark` block declares values identical to `:root`, so toggling the class changes nothing. Do not cite the reference as authority for dark styling — if the project under review needs dark mode, that is out of scope for this spec and should be raised with the user.
- **The token set is largely unused.** Apart from `--primary`, `:root` still holds stock shadcn neutrals while the rendered app draws its greys from the Tailwind palette and arbitrary values. Rules 6–8 therefore quote rendered values rather than token names. When the project under review *does* have a working token layer, prefer its token names and use these values to check what those tokens resolve to.
