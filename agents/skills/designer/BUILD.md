# Build mode

Reached when the request is to make something — "create an admin dashboard", "add a settings page", "redesign the pricing table".

The spec is an input to building, not a test applied afterwards. Establish it first (`SKILL.md`), then build against it and audit your own output.

## 1. Read the vocabulary before writing

The fastest way to satisfy a spec is to reuse what already satisfies it. Before writing markup, find what the project already has:

- The component library in use, and its variants — `Button`, `Card`, `Dialog` and the props they take
- The token layer — what colours, spacing, and radius names resolve to
- Two or three existing screens closest to the thing being built

Build from that vocabulary. A new hand-rolled button beside an existing `<Button variant="primary">` is a violation on the day it ships.

**Done when** the component and token names the build will use are known and named.

## 2. Build the whole surface

Cover the states, not just the happy path. A screen that renders only its populated case is half-built:

- **Empty** — no data yet, and the path out of it
- **Loading** — occupying the space the content will occupy, so the layout does not jump
- **Error** — what failed and what to do next
- **Overflowing** — long strings, many rows, small viewport

Every interactive element gets its hover, focus, and disabled treatment from the spec's component rules.

**Done when** every state above renders and the spec's numbered rules have all been applied.

## 3. Render it

Build fails silently in ways source review cannot catch, so get it on screen before claiming it works. Start the dev server, point the measure loop in [`MEASURING.md`](MEASURING.md) at the new route, and screenshot it at 1440, 768, and 375.

**Done when** the new surface has rendered at all three widths with a clean console.

## 4. Audit your own output

Run [`AUDIT.md`](AUDIT.md) steps 2–6 against what you just built, with one addition: compare the new surface's measurements against an existing screen. A tally that shows the new route using `13px` and `#4A5565` where the rest of the app uses `12px` and `#364153` means the build drifted, whatever the spec says in the abstract.

Auditing your own work invites waving it through — the rules you just applied feel already checked. They are not. Measure them the same way you would measure someone else's.

**Done when** every numbered rule holds a verdict and every violation is fixed and re-measured.

## 5. Report

Use the format at the end of `SKILL.md`, with **Fixed** reading as what the audit of your own build caught and corrected. Name the components and tokens reused, so the next build has a shorter step 1.
