# 05 · Enums with a fixed underlying type + switch

## Why it matters
Enums give names to states. C23's fixed underlying type makes their size and layout predictable, which matters for packed structs, file formats and hardware registers.

## Your task
- declare `enum Dir : unsigned char` with NORTH, EAST, SOUTH, WEST
- `turn_right`, `opposite`, and `dir_name` (use a switch)

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
