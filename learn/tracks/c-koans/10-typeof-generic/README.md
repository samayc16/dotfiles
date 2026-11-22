# 10 · typeof and _Generic: type-aware macros

## Why it matters
typeof (standard in C23) and _Generic give C a little compile-time polymorphism: macros that work for any type, picked by the compiler.

## Your task
- `SWAP(a, b)` works for any type (use `typeof`)
- `TYPE_NAME(x)` returns the type name string via `_Generic`
- `ABS(x)` dispatches to abs/labs/fabs via `_Generic`

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
