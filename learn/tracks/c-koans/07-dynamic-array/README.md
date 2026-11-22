# 07 · Dynamic memory: a growable vector

## Why it matters
Every language's list/vector is this under the hood. Writing one teaches allocation, growth strategy and ownership, and the sanitizer shows you instantly when you get it wrong.

## Your task
Implement `vec_push` (grow by doubling with realloc, return false if allocation fails), `vec_get` (bounds-checked, nullptr when out of range) and `vec_free`.

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
