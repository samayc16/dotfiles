# 03 · Lambdas, sorting and higher-order functions

## Why it matters
Functions are values in Python. Passing small lambdas as `key=` is the idiomatic way to sort, group, min/max by anything.

## Your task
- sort people by age, then name
- `make_multiplier(n)` returns a function
- `apply_all` calls each function on x
- `top_n_by(items, n, key)` returns the n largest by key

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
