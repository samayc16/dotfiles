# 01 · auto, structured bindings, std::format

## Why it matters
Modern C++ reads like a scripting language when you let the compiler deduce types and destructure values: less noise, fewer bugs.

## Your task
- `min_max` returns {smallest, largest}
- `total` sums the map's values using structured bindings
- `row` formats like `vim   |   7` (name left-aligned in 6, count right-aligned in 4)

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
