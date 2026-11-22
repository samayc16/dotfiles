# 09 · string_view and span

## Why it matters
string_view and span are cheap, non-owning windows onto someone else's data. They make APIs accept any contiguous string/array without copies.

## Your task
- `trim` whitespace off both ends (no copies)
- `split` on a separator into views
- `sum_middle` sums all but the first and last element via `subspan`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
