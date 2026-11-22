# 06 · Tagged unions

## Why it matters
Tagged unions are C's version of Rust enums or Swift enums with associated values: one type that can be one of several shapes, with the tag telling you which.

## Your task
Implement `make_circle`, `make_rect` and `area` for the tagged-union `struct Shape`.

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
