# 15 · async/await: gather, TaskGroup, timeouts

## Why it matters
async/await lets one thread juggle thousands of waiting operations (network, subprocesses). Knowing gather, TaskGroup and timeouts covers most real-world async code.

## Your task
- `fetch_all` runs every fetch CONCURRENTLY (the check times it)
- `fetch_grouped` does the same with a TaskGroup
- `with_timeout` returns None if the coroutine takes too long

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
