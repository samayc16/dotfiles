# 08 · optional, variant, expected

## Why it matters
These vocabulary types make 'maybe', 'one of several' and 'value or error' explicit in the type, instead of sentinel values, nullptrs or exceptions.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `std::optional<T>`, `std::nullopt` | a `T` or nothing | `std::optional<int> none = std::nullopt;` |
| `if (!opt)`, `*opt`, `opt.value_or(d)` | test, unwrap, unwrap with default | `none.value_or(7)` → `7` |
| `std::string_view` | read-only view of characters (more in koan 09) | `std::string_view s = "123";` |
| `std::from_chars(first, last, out)` | parse a number without exceptions; returns `{ptr, ec}` | `auto [p, ec] = std::from_chars(s.data(), s.data() + s.size(), n);` |
| `std::errc{}` | the "no error" value of `ec` | `ec == std::errc{}` |
| `std::variant<A, B>` | holds exactly one of the listed types | `std::variant<int, std::string> id = 7;` |
| `std::visit(visitor, v)` | calls the visitor overload matching the type held | see below |
| `template <class... Fs>`, `Fs...` | variadic template: a pack of types (the `overloaded` helper) | |
| `using Alias = Type;` | type alias | `using Id = std::variant<int, std::string>;` |
| `std::expected<T, E>` | C++23: a `T` or an error `E` | see below |
| `std::unexpected{e}` | build the error side | `return std::unexpected{"negative"};` |
| `.error()`, `.transform(f)`, `.and_then(f)` | read the error / map the value / chain a step that returns `expected` | |

```cpp
using Id = std::variant<int, std::string>;
std::string show(const Id& id) {
    return std::visit(overloaded{
        [](int n) { return "#" + std::to_string(n); },
        [](const std::string& name) { return name; },
    }, id);
}                                                     // show(7) == "#7"

std::expected<double, std::string> checked_sqrt(double x) {
    if (x < 0) return std::unexpected{"negative"};
    return std::sqrt(x);
}
auto r = checked_sqrt(16).transform([](double v) { return v + 1; });   // r == 5.0
```

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
