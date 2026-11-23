# 10 · enum class, to_underlying, using enum

## Why it matters
Scoped enums don't leak names or silently convert to int, so the compiler catches mixed-up flags. `using enum` keeps switches readable.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `enum class E : std::uint8_t { A, B };` | scoped enum with a 1-byte underlying type | `enum class Dir : std::uint8_t { N, E, S, W };` |
| `E::A` | enumerators must be qualified; no implicit conversion to `int` | `Dir d = Dir::S;` |
| `std::to_underlying(e)` | C++23: the integer value, explicitly | `std::to_underlying(Dir::S)` → `2` |
| `using enum E;` | C++20: bring the enumerators into scope (e.g. inside a `switch`) | see below |
| `std::is_convertible_v<A, B>`, `sizeof(T)` | type trait / size in bytes (test.cpp's static_asserts) | `sizeof(Dir)` → `1` |

```cpp
const char* arrow(Dir d) {
    switch (d) {
        using enum Dir;            // now N means Dir::N
    case N: return "^";
    case E: return ">";
    case S: return "v";
    case W: return "<";
    }
    return "?";
}
```

## Your task
- `Level` is a 1-byte `enum class` (Debug, Info, Warn, Error)
- `severity` returns the underlying number
- `label` returns "DBG"/"INF"/"WRN"/"ERR" using `using enum`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
