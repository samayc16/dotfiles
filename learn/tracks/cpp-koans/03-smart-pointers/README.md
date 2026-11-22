# 03 · RAII and smart pointers

## Why it matters
In modern C++ you almost never write new/delete. Ownership lives in the type: unique_ptr for one owner, shared_ptr for many, weak_ptr to observe without owning.

## Your task
- `List::push_front` and `length` for a singly-linked list owned by `unique_ptr`s
- `make_observer` returns a weak_ptr that expires when the shared object dies

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
