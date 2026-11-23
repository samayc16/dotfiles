# 08 · Function pointers and callbacks

## Why it matters
Function pointers are how C does callbacks, plugins, dispatch tables and generic algorithms like qsort.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `int (*f)(int, int)` | `f` is a pointer to a function taking two `int`s and returning `int` | `double (*op)(double) = sqrt;` |
| `typedef ... Name;` | a short name for a type; for function pointers it hides the `(*)` | `typedef bool (*Pred)(int);` |
| function name as a value | a function's name turns into a pointer to it; call through the pointer like a function | `Pred p = is_even; p(4)` |
| `static` function | visible only inside this file | `static bool is_even(int x)` |
| `default:` | the `switch` branch taken when no `case` matches | `default: return nullptr;` |
| `qsort(base, n, size, cmp)` | `<stdlib.h>` sort for any element type; `cmp(a, b)` returns < 0 (a first), 0, or > 0 (b first) | see below |
| `const void *` + cast | an untyped pointer; cast to the real type to read it | `*(const double *)a` |

```c
// ascending doubles (a different type and direction than the koan)
static int cmp_asc_double(const void *a, const void *b) {
    const double x = *(const double *)a;
    const double y = *(const double *)b;
    return (x > y) - (x < y);   // -1, 0 or 1; `x - y` could overflow for ints
}
qsort(prices, n, sizeof *prices, cmp_asc_double);
```

## Your task
- `map_inplace` applies a callback to every element
- `op_for('+')` returns the matching BinOp (+ - *), or nullptr
- `sort_desc` sorts descending with qsort and your comparator

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
