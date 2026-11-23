# 14 · C++26 sneak peek: pack indexing, = delete("why"), mdspan

## Why it matters
C++26 is the newest standard. Pack indexing removes a whole category of template metaprogramming tricks, deleted-with-reason gives readable errors, and mdspan is the standard multi-dimensional array view.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `pack...[i]` | C++26 pack indexing: the i-th element of a parameter pack | `template <class... Ts> auto second(Ts... xs) { return xs...[1]; }` |
| `sizeof...(pack)` | how many elements a pack has | `count_args(1, 2, 3)` → `3` |
| `= delete("reason")` | C++26: deleted function with your own error message | `void send(const char*) = delete("pass a std::string");` |
| `std::mdspan m(ptr, rows, cols)` | C++23 multi-dimensional view over flat, row-major data | `std::mdspan img(px.data(), 2, 3);` |
| `m[i, j]` | C++23 multi-dimensional subscript | `img[1, 2]` is `px[1 * 3 + 2]` |
| `auto [a, _] = pair;` | C++26 `_` placeholder: a name you won't use (may repeat) | `for (const auto& [_, age] : ages) total += age;` |
| `concept C = requires(T v) { f(v); };` | test.cpp asks "does this call compile?" (koan 11) | |

## Your task
- `first` / `last` with pack indexing
- forbid `process(double)` with a reason (the test checks it can't be called)
- `trace` sums the diagonal of a row-major matrix through `std::mdspan`
- `sum_firsts` uses the `_` placeholder for the ignored half of each pair

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
