---
name: designer
description: Design, audit, and repair UI against a style spec, driving a real browser with Playwright. Use to build new UI to a spec, to find and fix what looks wrong on existing screens, or to capture a spec from a reference site.
---

# Designer

Judge the **rendered** page, not the source. Code review answers "is this written well". This answers "does the thing on screen look right" — and then makes it right.

Three words carry every mode:

- **spec** — the style guide, token set, or house style in force. The spec is the authority on what "correct" means. A gap between the rendered page and the spec is a finding; your own taste is a Nit at most.
- **verdict** — every spec rule ends at `pass`, `violated`, or `n/a`. A rule with no verdict means the work is unfinished.
- **receipt** — a measured value or screenshot. Receipts do double duty: one proves the problem, and a second, taken after the edit, proves the fix. A change you did not re-measure is not a fix.

Measure, never eyeball. A screenshot cannot tell `#4A5568` from `#4A5569`, and "the spacing looks off" is not a finding. Drive the browser with the `playwright-cli` skill, and pull real numbers out of the page with the extractors in [`MEASURING.md`](MEASURING.md) — it also covers the two measurement traps that manufacture false findings.

## Pick the mode

| What was asked | Mode |
| --- | --- |
| Nothing, or "check this", or a diff/PR to look at | **Audit** — [`AUDIT.md`](AUDIT.md) |
| Build, add, or redesign something ("create an admin dashboard") | **Build** — [`BUILD.md`](BUILD.md) |
| Set up, capture, or update a style spec, usually with a reference URL | **Spec** — [`SPEC-SETUP.md`](SPEC-SETUP.md) |

Audit is the default. When the request is bare, audit what is currently on screen rather than asking which mode was meant.

## Establish the spec first

Every mode needs a spec before it renders anything, so this step is shared.

Locate it: a path or URL the user gave, a rules block they pasted, or the project's own conventions. When no spec was supplied, read [`SPEC-SOURCES.md`](SPEC-SOURCES.md) — it ranks what to derive from, and falls back to the house style in [`TSENTA-STYLE.md`](TSENTA-STYLE.md) when the project carries no design intent of its own.

Rewrite it as a numbered rule list before opening a browser. Each rule must be decidable by looking at a rendered page — turn "buttons feel consistent" into "primary buttons use `#15362B`, pill radius, 12px/500, 24px tall". A rule you cannot decide from the page is `n/a`; say so now rather than dropping it silently.

**Done when** a numbered rule list exists and every rule is decidable.

## Repair, don't just report

Every mode ends by fixing what it found. Findings are triaged, then acted on:

- **Blocker** — broken flow, unreadable content, or an accessibility failure. Fix it.
- **High** — a spec violation a user would notice. Fix it.
- **Medium** — a spec violation that survives a second glance. Fix it.
- **Nit** — your taste, not the spec's rule. Report it and leave the code alone unless the user asks.

Change the smallest thing that moves the rendered value onto the spec. Reach for the existing token, utility, or component variant the project already uses — a fix that introduces a new magic number trades one violation for another. When a violation repeats across many elements, fix the shared component rather than each call site.

Then re-run the measurement that produced the finding and record the new value. That second receipt is what closes the finding.

Leave a finding unfixed when the fix would reach outside the surface under review, when the spec rule itself looks wrong, or when two rules conflict. Say so and explain — an unfixed finding with a reason is a result; an unfixed finding left silent is a miss.

**Done when** every Blocker, High, and Medium holds a post-fix receipt or a written reason it was left.

## Report

Lead with what changed, not with a catalogue of what was wrong.

```markdown
### Designer: <surface>

Spec: <path or description> — <n> rules, <n> passed, <n> violated, <n> n/a
Screenshots: <directory>

#### Fixed

- <symptom> — spec rule <n> — `<before>` → `<after>` — `<file:line>`

#### Left alone

- <symptom> — spec rule <n> — <why>

#### Nits

- Nit: <symptom>
```

Empty sections are dropped. A run that found nothing reports the rule tally and says so.
