# CLAUDE.md

## Specific hard rules

### PHP coding standards

**Scope: PHP only.** Every rule in this section — whitespace *and* naming — applies
exclusively to `.php` files. Do not apply any of it to JavaScript, TypeScript, JSON, CSS,
YAML, shell, or any other language, and do not configure formatters/linters (Prettier,
Biome, ESLint) to emulate it outside PHP.

In every non-PHP language, follow that language's own standard conventions instead. For
JavaScript/TypeScript that means: `camelCase` variables and functions, `PascalCase` types
and classes, `UPPER_SNAKE_CASE` constants, and no spaces inside parentheses, brackets, or
generics — `if ( ! x )` is PHP, `if (!x)` is TypeScript.

White space:
Operators & Commas: Put spaces after commas and on both sides of operators (=, ===, &&, .=, etc.).
Parentheses: Put spaces inside opening/closing parentheses for control structures, function declarations, function calls, and nested logic (e.g., if ( $x ), func($arg )).
Array Keys: Add space around index only if it's a variable ($arr[ $var ] vs$arr['key']).
Casts: Use short, lowercase casts with no space ((int), (bool), (float)).
Increments/Decrements: No space between operator and variable ($i++, ++$i).
Switch: No space before case colon (case 'foo':).

Variable naming:
Everything—variables, functions, filenames, and hook names—uses snake_case. Classes use Snake_Case_With_Caps.
❌ $userProfile = getUserData();
✅ $user_profile = get_user_data();
❌ class UserProfileManager {}
✅ class User_Profile_Manager {}

## General rules

**These guidelines bias toward caution over speed. For trivial tasks, use judgment.**

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

* State your assumptions explicitly. If uncertain, ask.
* If multiple interpretations exist, present them - don't pick silently.
* If a simpler approach exists, say so. Push back when warranted.
* If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

* Minimize comments, only use when it genuinely explains confusing code.
* No features beyond what was asked.
* No abstractions for single-use code.
* No "flexibility" or "configurability" that wasn't requested.
* No error handling for impossible scenarios.
* If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

* Don't "improve" adjacent code, comments, or formatting.
* Don't refactor things that aren't broken.
* Match existing style, even if you'd do it differently.
* If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

* Remove imports/variables/functions that YOUR changes made unused.
* Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

* "Add validation" → "Write tests for invalid inputs, then make them pass"
* "Fix the bug" → "Write a test that reproduces it, then make it pass"
* "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]

```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.
