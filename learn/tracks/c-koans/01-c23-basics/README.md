# 01 · C23 basics: bool, nullptr, constexpr, binary literals

## Why it matters
C23 is the biggest C update in decades. It removes old macro hacks (stdbool.h, NULL) and adds compile-time constants, so modern C reads much closer to C++.

## Your task
- define `MASK` as a C23 `constexpr` binary literal 0b1111'0000
- `count_true` counts true values
- `first_positive` returns a pointer to the first positive element, or `nullptr`

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
