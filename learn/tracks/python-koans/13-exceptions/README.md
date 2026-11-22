# 13 · Exceptions: hierarchies, chaining, ExceptionGroup

## Why it matters
Good error types make failures debuggable. `raise ... from` keeps the original cause in tracebacks; ExceptionGroup reports several failures at once (validation, concurrent tasks).

## Your task
- `AppError` base + `NotFound(key)` subclass with a `.key` attribute
- `lookup` turns KeyError into NotFound, chained with `from`
- `validate_all` raises an ExceptionGroup of every invalid item
- `count_value_errors` uses `except*` to count ValueErrors in a group

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
