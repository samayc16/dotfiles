# 11 · Templates and concepts

## Why it matters
Concepts name the requirements a template needs, so misuse gives a one-line error instead of 200 lines of template spew, and your LSP can tell you what fits.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `template <class T> concept C = expr;` | a named compile-time yes/no question about a type | `template <class T> concept Small = sizeof(T) <= 4;` |
| `requires(const T& t) { ... }` | true if every expression inside compiles for `T` | see below |
| `{ t.f() } -> std::convertible_to<X>;` | ...and its result converts to `X` | |
| `std::integral<T>`, `std::floating_point<T>` | standard concepts; combine with `&&` / `\|\|` | `std::integral<char>` → true |
| `template <C T>` | constrained template: only types satisfying `C` | `template <std::integral T> T twice(T x);` |
| `template <C... Ts>`, `const Ts&... xs` | a pack of constrained types / a pack of parameters | |
| `(init + ... + expr)` | fold expression: expand the pack with an operator | `(0 + ... + xs)` |

```cpp
template <class T>
concept Named = requires(const T& t) {
    { t.name() } -> std::convertible_to<std::string>;
};
struct Cat { std::string name() const { return "tom"; } };
static_assert(Named<Cat> && !Named<int>);

template <class... Ts>
auto sum_all(Ts... xs) { return (0 + ... + xs); }   // sum_all(1, 2, 3) == 6
```

## Your task
- define concept `Shape` (has `area()` convertible to double)
- `total_area(shapes...)` sums any number of shapes with a fold expression
- `Number` concept (integral or floating point) and `clamp_to`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
