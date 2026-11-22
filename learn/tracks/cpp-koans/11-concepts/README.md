# 11 · Templates and concepts

## Why it matters
Concepts name the requirements a template needs, so misuse gives a one-line error instead of 200 lines of template spew, and your LSP can tell you what fits.

## Your task
- define concept `Shape` (has `area()` convertible to double)
- `total_area(shapes...)` sums any number of shapes with a fold expression
- `Number` concept (integral or floating point) and `clamp_to`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
