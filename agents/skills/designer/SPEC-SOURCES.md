# Deriving a spec

Reached when no style guide was supplied. Work down this list and stop at the first source that yields rules — each one below is weaker evidence of intent than the one above it.

1. **Written design system** — `DESIGN.md`, `STYLEGUIDE.md`, `CONTRIBUTING.md`, a `docs/design` directory, or a Storybook with docs pages. Written intent outranks everything below.
2. **Token definitions** — `tailwind.config.*`, CSS custom properties on `:root`, a `theme.ts`, or SCSS variable files. A token layer the project actually renders through is a spec by construction: the rule is that rendered values come from it, and anything outside it is a magic number. A token block that exists but is bypassed at render time is not this source — check a rendered element before trusting it.
3. **Component library conventions** — when the project uses shadcn/ui, Radix, MUI, Mantine, or similar, that library's variants and sizes are the vocabulary. A hand-rolled button beside an existing `<Button variant="primary">` violates the library's own contract.
4. **House style** — [`TSENTA-STYLE.md`](TSENTA-STYLE.md), measured from the Tsenta dashboard. This is the default when the project carries no design intent of its own: a new project, an early prototype, a standalone component, or a codebase whose conventions are too thin to decide from. Use it whole rather than picking rules from it — its density, weight, and radius choices depend on each other.
5. **Precedent** — the patterns already dominant in the app under review. Screenshot two or three comparable screens the change did not touch, extract their computed values with the tally in [`MEASURING.md`](MEASURING.md), and let the majority pattern become the rule. Reach for this over the house style only when the app clearly has a deliberate look of its own that the house style would fight.

A derived spec is a guess about intent. Put the numbered rule list at the top of the report and label where each rule came from, so a finding the user disagrees with resolves as "that rule is wrong" rather than "that review is wrong".

## Re-measuring the house style

`TSENTA-STYLE.md` is a cached measurement, so it goes stale when the reference site changes. Refresh it by running spec mode ([`SPEC-SETUP.md`](SPEC-SETUP.md)) against `https://dashboard.tsenta.com/dashboard` at 1440px.

The route sits behind auth and redirects to `/login`, so a fresh Playwright context reaches the marketing page instead of the dashboard — the global token block is still readable there, but component and density values are not. Use saved storage state or the user's authenticated Chrome, per the auth section of [`MEASURING.md`](MEASURING.md).
