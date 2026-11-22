# 01 · f-strings

## Why it matters
f-strings are how modern Python builds every string: logs, reports, CLI output. The format-spec mini-language (alignment, width, precision) saves you from manual padding.

## Your task
- `receipt_line` pads the item to 12 chars (left), qty to 3 (right), price to 8 with 2 decimals (right)
- `percent` renders a ratio as a percentage with one decimal
- `debug_expr` returns the `x=` self-documenting form

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
