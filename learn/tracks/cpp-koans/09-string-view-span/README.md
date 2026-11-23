# 09 · string_view and span

## Why it matters
string_view and span are cheap, non-owning windows onto someone else's data. They make APIs accept any contiguous string/array without copies.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sv.substr(pos, n)` | a smaller view of the same characters (no copy) | `std::string_view{"/usr/bin"}.substr(5)` → `"bin"` |
| `find_first_not_of(set)` / `find_last_not_of(set)` | index of the first / last char **not** in `set` | `std::string_view{"--x--"}.find_first_not_of('-')` → `2` |
| `std::string_view::npos` | "not found" (returned by every `find*`) | `std::string_view{"abc"}.find('z') == npos` |
| `sv.remove_prefix(n)` | shrink the view from the front | `kv.remove_prefix(4);  // "key=value" → "value"` |
| `constexpr std::string_view ws = " \t";` | a compile-time constant view | |
| `std::span<const T>` | view of any contiguous array: `std::array`, `std::vector`, C array | `std::span<const int> s = arr;` |
| `s.subspan(offset, count)` | a window into the span (count optional) | `s.subspan(1, 2)` |
| `std::array<T, N>` | fixed-size array with value semantics (test.cpp) | `std::array<int, 4> arr{1, 2, 3, 4};` |
| `std::accumulate(b, e, init)` | classic sum over an iterator range | `std::accumulate(arr.begin(), arr.end(), 0)` → `10` |

A view never owns its data: returning a `string_view` into a local `std::string` is a dangling pointer (ASan will tell you).

## Your task
- `trim` whitespace off both ends (no copies)
- `split` on a separator into views
- `sum_middle` sums all but the first and last element via `subspan`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
