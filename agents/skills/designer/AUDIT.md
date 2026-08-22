# Audit mode

The default. Find what is wrong with the rendered design, then fix it. Reached with a bare invocation, a "check this", or a diff to look at.

Establish the spec first (`SKILL.md`), then work down.

## 1. Find the surface

A bare invocation means "whatever is currently on screen": the running dev server, on the routes the working diff touches. Read the diff to know which routes those are; with no diff, audit the app's main route.

No dev server is a blocker on the whole run — ask the user for the URL rather than auditing the source as a substitute. Reading JSX and imagining the output is exactly what this skill exists to replace.

**Done when** a URL renders the surface under review.

## 2. Walk the flow

Drive the primary path end to end — click through it, type into it, tab into it. Hover interactive elements and trigger their disabled and loading states where they exist. Screenshot each distinct state; these become receipts.

State that never renders never gets audited, so reach the states behind interaction rather than auditing the first paint alone.

**Done when** every route the change touches has rendered and every interactive element in it has been exercised.

## 3. Give every rule a verdict

Walk the numbered list from `SKILL.md`. For each rule, decide from measured values using the extractors in [`MEASURING.md`](MEASURING.md).

The property tally is the fastest way in: the long tail of any distribution is where violations live. One element at `13px` among forty at `12px` is a finding; the tally surfaces it without knowing where to look.

**Done when** every numbered rule holds a verdict, and every `violated` holds a receipt.

## 4. Viewports

Run the measure loop at 1440, 768, and 375. At every width, confirm the page scrolls only vertically, elements stay clear of each other, and text stays inside its container — the tally reports horizontal overflow per width, and `snapshot --boxes` turns overlap into arithmetic rather than judgement.

Use the spec's own breakpoints instead when it names them, checking one width either side of each.

**Done when** each width has a screenshot and a verdict.

## 5. Baseline checks

Run the sections of [`CHECKS.md`](CHECKS.md) that match the surface. These hold regardless of the spec — a spec adds rules, it never waives accessibility or a clean console.

**Done when** every applicable section of `CHECKS.md` has a verdict.

## 6. Fix and prove

Apply the repair rules in `SKILL.md`: fix Blocker, High, and Medium; report Nits without touching them.

Fix in one pass, then re-run the measure loop once and diff the JSON against the pre-fix run. One re-run confirms every fix at once and catches the fix that broke a neighbour — a spacing change that fixes a card and pushes the sidebar into overflow shows up here and nowhere else.

When what remains is taste rather than spec — a Nit worth raising, or a rule the measurements cannot settle — offer `show --annotate` and let the user mark up the page directly.

**Done when** the post-fix run shows every fixed rule passing and no rule that regressed from `pass`.

Then report in the format at the end of `SKILL.md`.
