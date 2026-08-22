# Spec mode

Reached when the request is to set up, capture, or update a style spec — usually with a reference URL, sometimes from an app the user already has.

The output is a file of numbered, decidable rules that later runs use as their authority. [`TSENTA-STYLE.md`](TSENTA-STYLE.md) is one produced this way; match its shape.

## 1. Agree the reference and the destination

Confirm two things before measuring:

- **What to measure** — a URL, or the project's own screens. When given a URL behind a login, follow the auth section of [`MEASURING.md`](MEASURING.md) and ask the user to sign in rather than entering credentials.
- **Where it lands** — a file in the project (`DESIGN.md`, `STYLEGUIDE.md`) when it governs one codebase, or a file beside this skill when it is a house style spanning projects.

Measure more than one page when the reference has more than one. A spec derived from a single screen inherits that screen's blind spots — a dashboard alone teaches nothing about forms or empty states. Two or three routes is usually enough to tell a rule from a coincidence.

**Done when** the routes to measure and the destination path are settled.

## 2. Measure

Run the extractors in [`MEASURING.md`](MEASURING.md) against each route at 1440px: the property tally, the component specs, and the token resolution. Capture a screenshot per route to sanity-check the numbers against what the page actually looks like.

**Done when** every chosen route has a tally, component specs, and resolved tokens.

## 3. Turn measurements into rules

A distribution is not a rule. Convert it:

- **The mode becomes the rule, the tail becomes the exception.** `12px ×37, 11px ×29, 13px ×22, 21px ×1` is a scale of `11/12/13` and one outlier — write the scale, drop the outlier.
- **Frequency ranks the ramp.** The most-used text colour is the body colour whatever the token is named; order the ramp by count.
- **Name what the accent is for, not just its value.** "`#15362B` on primary actions and active state only" is decidable; "the brand colour is `#15362B`" is not.
- **Round only when the evidence is noisy.** Half-pixel sizes repeated across many elements are authored intent — keep them.

Number every rule, and phrase each so a later run can answer `pass` or `violated` by measuring one property.

Convert colours to hex for readability, keeping the authored value alongside — a rule quoting `oklch(0.373 0.034 259.733)` is unreadable, and one quoting only `#364153` cannot be traced back.

**Done when** every rule is numbered, decidable, and traceable to a measurement.

## 4. Record what the reference does not cover

The gaps matter as much as the rules. Write down what the reference could not teach, so later runs do not treat silence as permission:

- Modes the reference lacks — dark mode that is declared but never differs from light, for example
- Components absent from the routes measured
- A token layer the app declares but does not render through, which makes token names unsafe to cite as rules

**Done when** the known gaps are listed in the spec file.

## 5. Wire it up

Write the file, then make it reachable. A spec nothing points at never fires:

- In-project — name it in the project's `CLAUDE.md` or `AGENTS.md` so it is found without being asked for
- House style — add it to the ranking in [`SPEC-SOURCES.md`](SPEC-SOURCES.md), and say when it outranks a project's own conventions

Close by showing the user the numbered rules and asking which ones they disagree with. A spec is a claim about their intent, and the cheapest time to correct it is before anything has been audited against it.
