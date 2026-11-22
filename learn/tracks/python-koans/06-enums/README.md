# 06 · Enums

## Why it matters
Enums turn magic strings and numbers into named, typo-proof constants that your editor can autocomplete and your type checker can verify.

## Your task
- `Color` with RED/GREEN/BLUE and `complement()` (RED↔GREEN, BLUE↔BLUE)
- `Level` is an IntEnum DEBUG=10 INFO=20 ERROR=40
- `Status` is a StrEnum TODO='todo' DONE='done'

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
