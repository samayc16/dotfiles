# 10 · enum class, to_underlying, using enum

## Why it matters
Scoped enums don't leak names or silently convert to int, so the compiler catches mixed-up flags. `using enum` keeps switches readable.

## Your task
- `Level` is a 1-byte `enum class` (Debug, Info, Warn, Error)
- `severity` returns the underlying number
- `label` returns "DBG"/"INF"/"WRN"/"ERR" using `using enum`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
