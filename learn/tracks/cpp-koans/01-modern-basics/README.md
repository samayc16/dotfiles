# 01 · auto, structured bindings, std::format

## Why it matters
Modern C++ reads like a scripting language when you let the compiler deduce types and destructure values: less noise, fewer bugs.

## Modern C++ in 2 minutes

**How a koan runs.** `koan.cpp` has no `main`. The read-only `test.cpp` does `#include <koan.cpp>`, calls your
functions and checks the results. The checker compiles both with:

```
clang++ -std=c++26 -Wall -Wextra -g -O0 -fsanitize=address,undefined ...
```

so you get the newest standard library, all common warnings, and AddressSanitizer/UBSan to catch double frees,
use-after-free and overflow at runtime.

**Run it:** `learn check` (or `<leader>lc`). `warning:` lines are fine; each `CHECK` prints one line:

```
  ✗ row("vim", 7) == "vim   |   7" — got 'vim|7'

  0/3 checks passing
```

**A compile error:** read the first `error:` line (file:line:col). The `note:` lines after it point into library
headers and can usually be skipped. Format strings are checked at compile time, so two `{}` with one argument is:

```
koan.cpp:5:24: error: call to consteval function 'std::basic_format_string<char, ...>' is not a constant expression
    5 |     return std::format("{} v{}", tool);
note: ... "Argument index outside the valid range"
```

**Habits this track assumes**

| Habit | Why |
|---|---|
| take inputs as `const T&` (or a view, koan 09) | no copy, no mutation |
| brace-initialise: `int n{0};`, `return {a, b};` | no silent narrowing; works for every type |
| `auto` when the type is obvious or unspeakable | less noise; `K` or inlay hints show the real type |
| no raw `new`/`delete` (except koan 02) | ownership lives in types (koan 03) |
| `(void)x;` in starters | silences "unused parameter"; delete it once you use `x` |

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `auto x = expr;` | type deduced from the initializer | `auto ratio = 0.75;  // double` |
| `return {a, b};` | brace-initialise the declared return type | `std::pair<char, int> grade() { return {'A', 93}; }` |
| `const auto [a, b] = pair_or_struct;` | structured binding: unpack members into names | `const auto [letter, score] = grade();` |
| `for (const auto& x : container)` | range-for; `const auto&` = read-only, no copy | `for (const auto& w : words) ...` |
| `std::ranges::minmax(r)` | smallest and largest in one pass, as `.min` / `.max` | `std::ranges::minmax(std::vector{7, 2, 9}).max` → `9` |
| `std::format("{:>5}", x)` | Python-style formatting; `<` left, `>` right, `^` centre, number = width | `std::format("[{:>5}]", 42)` → `"[   42]"` |
| `{{` `}}` | literal braces inside a format string (used by test.cpp) | `std::format("{{{}}}", 1)` → `"{1}"` |

```cpp
std::map<std::string, int> temps{{"oslo", 4}, {"lima", 19}};
int hottest = 0;
for (const auto& [city, t] : temps) {   // each element is a std::pair<const std::string, int>
    if (t > hottest) hottest = t;
}
```

## Your task
- `min_max` returns {smallest, largest}
- `total` sums the map's values using structured bindings
- `row` formats like `vim   |   7` (name left-aligned in 6, count right-aligned in 4)

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
