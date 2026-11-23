# 06 · Ranges and views

## Why it matters
Views are lazy, composable pipelines: shell pipes for data. Nothing is computed until you iterate, so even infinite sequences work.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `r \| adaptor` | pipe a range into a view adaptor; read left to right, like a shell pipe | `words \| std::views::take(2)` |
| `std::views::filter(pred)` | keep elements where `pred` is true (lazy) | `std::views::filter([](int x) { return x > 0; })` |
| `std::views::transform(f)` | apply `f` to every element (lazy) | `std::views::transform([](int x) { return x * 10; })` |
| `std::ranges::to<std::vector>()` | C++23: run the pipeline and collect into a container | see below |
| `std::views::iota(a)` / `iota(a, b)` | a, a+1, a+2, … forever / up to b (exclusive) | `std::views::iota(1, 4)` → 1 2 3 |
| `std::views::take(n)` | first `n` elements; makes an infinite view finite | |
| `std::views::zip(a, b)` | C++23: pairs of elements, stops at the shorter range | `for (auto [n, s] : std::views::zip(names, scores))` |
| `constexpr bool f(...)` | a function that may also run at compile time (koan 12) | |
| `static_cast<long>(x)` | explicit conversion, here to multiply without `int` overflow | |

```cpp
auto odds = std::views::iota(1)                                // 1, 2, 3, ... (infinite)
          | std::views::filter([](int x) { return x % 2; })
          | std::views::take(3)
          | std::ranges::to<std::vector>();                    // {1, 3, 5}
```

## Your task
- `evens_squared` via filter | transform | to<vector>
- `first_primes(n)` from an infinite `iota`
- `dot` (dot product) using `views::zip`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
