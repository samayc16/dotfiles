# 04 · Structs, designated initializers, compound literals

## Why it matters
Structs are how C models data. Designated initializers make construction self-documenting and immune to field reordering.

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
