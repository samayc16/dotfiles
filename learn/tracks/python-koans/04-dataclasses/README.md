# 04 · Dataclasses

## Why it matters
Dataclasses generate __init__, __repr__ and __eq__ (and optionally ordering) from type-annotated fields. They are the standard way to model plain data in modern Python.

## Your task
- Turn `Item` into a dataclass with a per-instance `tags` list and price validation
- Make `Version` an ordered dataclass with a `parse('1.2.3')` classmethod

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
