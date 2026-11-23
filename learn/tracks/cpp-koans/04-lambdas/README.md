# 04 · Lambdas and captures

## Why it matters
Lambdas are inline function objects. Captures decide what they remember and whether they copy or borrow it: the source of both elegant code and dangling-reference bugs.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `[](int x) { return x * 3; }` | lambda: `[captures](params) { body }` | `auto triple = [](int x) { return x * 3; };` |
| `[&x]` | capture `x` by reference: writes change the original | `[&hits](int x) { if (x > 0) ++hits; }` |
| `[x]`, `[=]` | capture `x` / everything used, by copy | `[=] { return a + b; }` |
| `[n = 0]` | init-capture: a new variable living inside the lambda | `[seen = 0] { ... }` |
| `mutable` | lets the lambda change its by-copy captures between calls | see below |
| `[](auto x)` | generic lambda: works for any type that supports the body | `[](auto x) { return x * x; }` on `3` and `1.5` |
| `std::function<R(Args)>` | holds any callable with that signature | `std::function<bool(int)> pos = [](int x) { return x > 0; };` |
| `std::ranges::for_each(r, f)` | call `f` on every element | `std::ranges::for_each(v, [](int x) { ... });` |
| `auto f(auto a)` | `auto` parameters on a normal function make it a template | `auto twice(auto x) { return x + x; }` |
| `inline auto name = ...;` | a global variable (here holding a lambda) | |

```cpp
auto delta = [last = 0](int x) mutable {   // remembers the previous input
    int d = x - last;
    last = x;
    return d;
};
delta(5);   // 5
delta(8);   // 3
```

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
