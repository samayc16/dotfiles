# 09 · Bit manipulation

## Why it matters
Hardware registers, protocols, flags, hashes and compression all live at the bit level. If you touch Verilog, this is the software side of the same thinking.

## Your task
Implement `is_power_of_two`, `set_bit`, `clear_bit`, `toggle_bit`, `popcount` and `extract_field`.

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
