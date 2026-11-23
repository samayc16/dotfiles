# 10 · typeof and _Generic: type-aware macros

## Why it matters
typeof (standard in C23) and _Generic give C a little compile-time polymorphism: macros that work for any type, picked by the compiler.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `#define M(a) ...` | function-like macro: text substitution before compiling | `#define SQUARE(x) ((x) * (x))` |
| `(x)` in a macro | parenthesise every argument and the whole result | `SQUARE(1 + 2)` → `9`, not `5` |
| `\` at line end | continue a macro on the next line | see below |
| `do { ... } while (0)` | wraps a multi-statement macro so it acts as ONE statement (safe after a brace-less `if`) | see below |
| `typeof(expr)` | C23: the type of an expression, usable in a declaration | `typeof(price) copy = price;` |
| `_Generic((x), T: e, ..., default: e)` | compile-time switch on the TYPE of `x`; the whole thing becomes the chosen expression | `_Generic((x), float: "f", default: "?")` |
| `_Generic(...)(x)` | when the branches are function names, call whichever was chosen | `_Generic((x), float: sqrtf, double: sqrt)(x)` |
| literal types | `42` is `int`, `4.2` is `double`, `4L` is `long`, `'c'` is `int` (in C) | |

```c
#define CLAMP_UP(v, lo)                       \
    do {                                      \
        typeof(v) clamp_lo_ = (lo);           \
        if ((v) < clamp_lo_) (v) = clamp_lo_; \
    } while (0)

if (ready) CLAMP_UP(speed, 10);   // one statement, even without braces
```

## Your task
- `SWAP(a, b)` works for any type (use `typeof`)
- `TYPE_NAME(x)` returns the type name string via `_Generic`
- `ABS(x)` dispatches to abs/labs/fabs via `_Generic`

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
