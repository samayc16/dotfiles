# 07 · std::format and custom formatters

## Why it matters
std::format (and std::print) is type-safe printf: no format-string crashes, works with your own types, and the same mini-language as Python's f-strings.

## Your task
- `hex_and_binary(255)` → `0xff 11111111`
- `banner("ok")` → `***ok****` (centred in 9 with *)
- make `Point` formattable as `(x, y)`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
