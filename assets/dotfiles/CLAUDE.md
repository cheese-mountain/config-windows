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

