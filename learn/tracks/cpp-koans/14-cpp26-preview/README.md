# 14 · C++26 sneak peek: pack indexing, = delete("why"), mdspan

## Why it matters
C++26 is the newest standard. Pack indexing removes a whole category of template metaprogramming tricks, deleted-with-reason gives readable errors, and mdspan is the standard multi-dimensional array view.

## Your task
- `first` / `last` with pack indexing
- forbid `process(double)` with a reason (the test checks it can't be called)
- `trace` sums the diagonal of a row-major matrix through `std::mdspan`
- `sum_firsts` uses the `_` placeholder for the ignored half of each pair

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
