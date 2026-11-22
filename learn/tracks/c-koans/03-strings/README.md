# 03 · Strings, safely

## Why it matters
Most famous C security bugs are string overflows. Bounded APIs like snprintf, plus a sanitizer that screams on overflow, are how professionals write string code.

## Your task
- `my_strlen` without calling strlen
- `copy_bounded` copies safely, returns `true` if it had to truncate
- `count_words` counts whitespace-separated words
- `to_upper` uppercases in place

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
