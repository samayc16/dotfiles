# 05 · Containers and algorithms

## Why it matters
The standard library's containers and algorithms (with C++20 ranges and projections) replace most hand-written loops with intent-revealing one-liners.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `std::unordered_map<K, V>` | hash map (like a Python dict, no order) | `std::unordered_map<std::string, int> bank;` |
| `m[key]` | reference to the value; **inserts** `V{}` (0 for `int`) if missing | `bank["bob"] += 5;` |
| `std::vector<T> v(first, last)` | build a vector from an iterator range | `std::vector<std::pair<std::string, int>> v(m.begin(), m.end());` |
| `std::ranges::sort(v, cmp)` | sort; `cmp(a, b)` returns true if `a` goes first | `std::ranges::sort(ws, std::greater{});  // descending` |
| `std::ranges::sort(v, {}, proj)` | projection: compare by a member/function | `std::ranges::sort(ws, {}, &std::string::size);` |
| `std::erase_if(c, pred)` | remove every matching element (C++20) | `std::erase_if(s, [](char c) { return c == ' '; });` |
| `std::ranges::fold_left(r, init, op)` | C++23 fold/reduce | `std::ranges::fold_left(v, 0, std::plus{})` → sum |
| `std::plus{}`, `std::multiplies{}`, `std::greater{}` | operators as function objects | |
| `1L` | a `long` literal (so the fold accumulates in `long`) | `0L` |

## Your task
- `word_freq` counts words
- `top_k` returns the k most frequent (ties: alphabetical)
- `drop_negatives` removes negatives in place
- `product` multiplies with `std::ranges::fold_left`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
