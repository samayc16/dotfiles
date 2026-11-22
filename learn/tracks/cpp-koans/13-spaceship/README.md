# 13 · The spaceship operator <=>

## Why it matters
One defaulted operator gives you all six comparisons, consistently. Custom orderings (weak/partial) express 'equivalent but not identical' precisely.

## Your task
- default `<=>` for `Version` (compare major, minor, patch)
- `CiString` compares case-insensitively with `std::weak_ordering`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
