# 08 · optional, variant, expected

## Why it matters
These vocabulary types make 'maybe', 'one of several' and 'value or error' explicit in the type, instead of sentinel values, nullptrs or exceptions.

## Your task
- `parse_int` → `std::optional<int>`
- `kind_of` visits a variant
- `safe_div` → `std::expected<int, std::string>` and `half_of_parsed` chains with `and_then`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
