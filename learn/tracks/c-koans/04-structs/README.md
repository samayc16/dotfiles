# 04 · Structs, designated initializers, compound literals

## Why it matters
Structs are how C models data. Designated initializers make construction self-documenting and immune to field reordering.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `struct Name { T f; ... };` | declare a struct type; you write `struct Name` every time you use it | `struct Color { int r, g, b; };` |
| `.f` | member access, nested too | `c.r = 255;`, `pal.fg.g` |
| `{.f = v, ...}` | designated initializer: fields by name, any order; missing ones become 0 | `struct Color red = {.r = 255};` |
| `(struct T){...}` | compound literal: an unnamed struct value you can pass or return | `paint((struct Color){.g = 128});` |
| `{0}`, `{}` | zero every field (`{}` is new in C23) | `struct Color black = {};` |
| pass / return by value | structs are copied in and out; the caller's copy is untouched | |
| `f(void)` | a function with no parameters (`f()` meant "unspecified" before C23) | `struct Color random_color(void);` |

```c
struct Palette { struct Color bg; struct Color fg; };
struct Palette night = {.bg = {.r = 0}, .fg = {.r = 255, .g = 255, .b = 255}};  // nested
```

## Your task
- `midpoint` returns a new Point (use a compound literal)
- `rect_area` computes the area
- `unit_square` returns {min {0,0}, max {1,1}} using designated initializers

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
