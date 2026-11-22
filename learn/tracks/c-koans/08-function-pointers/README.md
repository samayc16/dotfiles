# 08 · Function pointers and callbacks

## Why it matters
Function pointers are how C does callbacks, plugins, dispatch tables and generic algorithms like qsort.

## Your task
- `map_inplace` applies a callback to every element
- `op_for('+')` returns the matching BinOp (+ - *), or nullptr
- `sort_desc` sorts descending with qsort and your comparator

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
