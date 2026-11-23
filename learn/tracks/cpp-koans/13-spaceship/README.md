# 13 · The spaceship operator <=>

## Why it matters
One defaulted operator gives you all six comparisons, consistently. Custom orderings (weak/partial) express 'equivalent but not identical' precisely.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `a <=> b` | three-way compare: result is `< 0`, `== 0` or `> 0` | `(1 <=> 2) < 0` → true |
| `auto operator<=>(const T&) const = default;` | compiler writes `<` `<=` `>` `>=` (and `==`), comparing members in declaration order | see below |
| `std::strong_ordering` | equal means identical (ints, strings) | |
| `std::weak_ordering` | "equivalent" may still differ (e.g. case-insensitive, by absolute value) | |
| custom `operator==` | a hand-written `<=>` does **not** give you `==`; write it too | |
| `std::ranges::transform(in, out, f)` | write `f(x)` for each element (the starter's `lower`) | |

```cpp
struct Date {
    int y, m, d;
    auto operator<=>(const Date&) const = default;   // Date{2024, 1, 2} < Date{2024, 2, 1}
};

struct Mag {                                          // compares by absolute value
    int v;
    std::weak_ordering operator<=>(const Mag& o) const { return std::abs(v) <=> std::abs(o.v); }
    bool operator==(const Mag& o) const { return std::abs(v) == std::abs(o.v); }
};                                                    // Mag{-3} == Mag{3}
```

## Your task
- default `<=>` for `Version` (compare major, minor, patch)
- `CiString` compares case-insensitively with `std::weak_ordering`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
