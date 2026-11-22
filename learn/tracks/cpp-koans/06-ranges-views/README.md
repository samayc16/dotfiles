# 06 · Ranges and views

## Why it matters
Views are lazy, composable pipelines: shell pipes for data. Nothing is computed until you iterate, so even infinite sequences work.

## Your task
- `evens_squared` via filter | transform | to<vector>
- `first_primes(n)` from an infinite `iota`
- `dot` (dot product) using `views::zip`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
