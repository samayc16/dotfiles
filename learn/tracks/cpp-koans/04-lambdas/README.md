# 04 · Lambdas and captures

## Why it matters
Lambdas are inline function objects. Captures decide what they remember and whether they copy or borrow it: the source of both elegant code and dangling-reference bugs.

## Your task
- `make_counter` returns a lambda counting 1, 2, 3...
- `sum_with` adds every element into `total` via a by-reference capture inside `std::ranges::for_each`
- `add` is a generic lambda
- `compose(f, g)` returns x ↦ f(g(x))

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
