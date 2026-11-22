# 14 · pathlib and the walrus operator

## Why it matters
pathlib replaces os.path string juggling with objects (`folder / 'a.txt'`). The walrus operator assigns inside an expression, which tidies read loops.

## Your task
- `count_lines(folder, pattern)` sums lines over matching files
- `longest_line(path)` returns the longest line
- `read_chunks(stream, size)` yields chunks using `:=`

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
