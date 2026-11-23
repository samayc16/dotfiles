# 01 · C23 basics: bool, nullptr, constexpr, binary literals

## Why it matters
C23 is the biggest C update in decades. It removes old macro hacks (stdbool.h, NULL) and adds compile-time constants, so modern C reads much closer to C++.

## C23 in 2 minutes

**How a koan runs:** your `koan.c` has no `main`. The read-only `test.c` does `#include <koan.c>` and calls your functions, built as one program with:

```
clang -std=c23 -Wall -Wextra -g -O0 -fsanitize=address,undefined test.c -lm
```

**Run it:** `learn check` (or `<leader>lc`). Each `CHECK` prints ✓ or ✗ with what it got, then a total:

```
  ✗ count_true(flags, 4) == 3 — expected 3, got 0
  0/4 checks passing
```

**Compile errors** come first: `file:line:col: error:` and a caret under the spot. Warnings don't fail the check, but read them.

```
koan.c:3:39: error: expected ';' after top level declarator
    3 | constexpr unsigned LIMIT = 0b0110'0100
      |                                       ^
```

**Sanitizers** turn silent memory bugs and undefined behaviour into a report with the exact line. Read the first frame in `koan.c`:

```
koan.c:10:5: runtime error: store to null pointer of type 'int'
    #0 in vec_push koan.c:10
```

**What C23 changed** (vs the C99/C11 you may know):

| Before | C23 |
|---|---|
| `#include <stdbool.h>` | `bool`, `true`, `false` are keywords |
| `NULL` | `nullptr`, a real null-pointer constant |
| `#define N 8` | `constexpr int N = 8;` (typed, scoped) |
| `__typeof__` (GNU) | `typeof(x)`, `typeof_unqual(x)` |
| `_Static_assert(c, "msg")` | `static_assert(c)` (message optional) |
| `enum E { ... }` (compiler picks the size) | `enum E : uint8_t { ... }` |
| `0x0F`, `= {0}` | `0b0000'1111` (binary + digit separators), `= {}` |

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `bool`, `true`, `false` | C23 keywords, no `#include <stdbool.h>` | `bool done = false;` |
| `nullptr` | C23 null pointer constant (replaces `NULL`) | `const char *name = nullptr;` |
| `constexpr T NAME = v;` | compile-time constant with a real type, instead of `#define` | `constexpr int MAX_USERS = 64;` |
| `0b...` | binary literal | `0b101` → `5` |
| `'` inside a number | digit separator, ignored by the compiler | `1'000'000`, `0b0000'0011` → `3` |
| `size_t`, `%zu` | unsigned type for sizes and counts (`<stddef.h>`); printed with `%zu` | `size_t n = sizeof(double);` |
| `const int *p` | pointer to ints you promise not to modify through `p` | `const int *last = &xs[n - 1];` |
| `&xs[i]` | the address of element `i` (what a "pointer to the element" is) | `return &names[0];` |
| `(void)x;` | starter trick: marks `x` as used to silence `-Wunused-parameter`; delete it once you use `x` | |
| `240u` | `u` suffix: an unsigned literal | `7u` |

## Your task
- define `MASK` as a C23 `constexpr` binary literal 0b1111'0000
- `count_true` counts true values
- `first_positive` returns a pointer to the first positive element, or `nullptr`

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
