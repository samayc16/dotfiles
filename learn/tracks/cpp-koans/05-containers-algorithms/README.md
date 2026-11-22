# 05 · Containers and algorithms

## Why it matters
The standard library's containers and algorithms (with C++20 ranges and projections) replace most hand-written loops with intent-revealing one-liners.

## Your task
- `word_freq` counts words
- `top_k` returns the k most frequent (ties: alphabetical)
- `drop_negatives` removes negatives in place
- `product` multiplies with `std::ranges::fold_left`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
