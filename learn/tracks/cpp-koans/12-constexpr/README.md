# 12 · constexpr and consteval: compile-time computation

## Why it matters
Work done at compile time costs nothing at runtime and is checked by the compiler. In hardware-adjacent code, lookup tables and bit masks are often built this way.

## Your task
- `factorial` is constexpr
- `square` is consteval
- `squares` is a constexpr std::array table of i² for i in 0..9
- the test file static_asserts all of it

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
