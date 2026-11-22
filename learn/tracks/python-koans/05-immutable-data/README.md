# 05 · Immutable data: frozen dataclasses, slots, replace()

## Why it matters
Immutable values can't be changed behind your back, can be dict keys/set members, and are safe to share. Producing a new copy instead of mutating is a habit that removes whole classes of bugs.

## Your task
- `Point` is frozen, slotted, and `moved()` returns a NEW point
- `Inventory.added()` returns a new inventory, leaving the original untouched

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
