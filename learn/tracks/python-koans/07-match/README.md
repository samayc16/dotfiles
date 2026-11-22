# 07 · Structural pattern matching

## Why it matters
match/case destructures data while it branches. It replaces chains of isinstance/len/key checks with patterns that read like the data's shape.

## Your task
- `describe(shape)`: 'circle r=2', 'square 3', 'rect 2x5', or 'unknown'
- `handle(command)`: 'going north', 'taking sword, shield', 'bye', or 'what?'
- `on_event(event)`: 'click at 3,4', 'key q', or 'ignored'

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
