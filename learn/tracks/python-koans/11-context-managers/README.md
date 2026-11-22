# 11 · Context managers

## Why it matters
`with` guarantees cleanup (closing files, releasing locks, restoring state) even when exceptions fly. Writing your own is one decorator away.

## Your task
- `Timer` measures the time spent inside its `with` block in `.elapsed`
- `working_dir(path)` switches cwd and ALWAYS restores it, even on error

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
