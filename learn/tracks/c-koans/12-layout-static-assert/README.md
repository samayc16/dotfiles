# 12 · Memory layout, padding and static_assert

## Why it matters
Struct layout decides memory use, cache behaviour, and whether your struct matches a file format, network packet or hardware register map. static_assert turns layout assumptions into compile errors.

## Your task
Reorder the fields of `struct Packet` (don't change their types) so it packs into 8 bytes. The check fails to COMPILE until you do: read the static_assert message.

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
