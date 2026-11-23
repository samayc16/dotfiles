# 12 · constexpr and consteval: compile-time computation

## Why it matters
Work done at compile time costs nothing at runtime and is checked by the compiler. In hardware-adjacent code, lookup tables and bit masks are often built this way.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `constexpr` function | may run at compile time when its arguments are constants; also callable at runtime | `constexpr int cube(int x) { return x * x * x; }` |
| `consteval` function | **must** run at compile time (an "immediate function") | `consteval int kib(int n) { return n * 1024; }` |
| `constexpr auto x = f();` | a variable computed by the compiler | `constexpr auto pow2 = powers();` |
| `static_assert(f(3) == 27);` | proves the value at compile time | `static_assert(cube(3) == 27);` |

```cpp
constexpr std::array<int, 5> powers() {   // loops and assignments are fine in constexpr
    std::array<int, 5> t{};
    for (int i = 0; i < 5; ++i) t[i] = 1 << i;
    return t;
}
constexpr auto pow2 = powers();           // {1, 2, 4, 8, 16}, built by the compiler
static_assert(pow2[4] == 16);
```

## Your task
- `factorial` is constexpr
- `square` is consteval
- `squares` is a constexpr std::array table of i² for i in 0..9
- the test file static_asserts all of it

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
