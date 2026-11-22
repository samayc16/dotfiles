# 08 · Generators and lazy iteration

## Why it matters
Generators produce values on demand, so you can process infinite streams or huge files in constant memory, and compose pipelines like shell pipes.

## Your task
Implement `fib`, `take`, `chunked`, `flatten_deep` and `running_total` as generators (use `yield`).

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
