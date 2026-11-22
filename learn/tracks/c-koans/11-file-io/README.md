# 11 · File I/O

## Why it matters
Reading and writing files, and checking every call that can fail, is everyday systems programming. It's also the C behind every shell tool you use.

## Your task
Implement `write_lines`, `count_lines` (-1 if the file can't be opened) and `sum_numbers` (sums whitespace-separated integers).

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
