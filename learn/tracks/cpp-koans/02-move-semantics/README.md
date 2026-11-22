# 02 · Move semantics and the rule of five

## Why it matters
Moving transfers ownership instead of copying it: it's why returning a huge vector by value is cheap. Writing one by hand shows what std::vector and std::unique_ptr do for you.

## Your task
`Buffer` owns a heap array. Make it movable (noexcept), non-copyable, and leave moved-from buffers empty (`size() == 0`, `data() == nullptr`). AddressSanitizer will catch double frees.

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
