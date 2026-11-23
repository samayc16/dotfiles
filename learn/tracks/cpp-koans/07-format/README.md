# 07 · std::format and custom formatters

## Why it matters
std::format (and std::print) is type-safe printf: no format-string crashes, works with your own types, and the same mini-language as Python's f-strings.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `{:x}` / `{:#x}` | hex / hex with `0x` prefix (`o` octal, `b` binary) | `std::format("{:#x}", 31)` → `"0x1f"` |
| `{:04b}` | `0` = pad with zeros, `4` = width | `std::format("{:04b}", 5)` → `"0101"` |
| `{:-<7}` | fill char, then alignment `<` `>` `^`, then width | `std::format("{:-<7}", "ab")` → `"ab-----"` |
| `{:+.2f}` | sign, precision, fixed-point | `std::format("{:+.2f}", 3.14159)` → `"+3.14"` |
| `template <> struct std::formatter<T>` | explicit specialisation: teach a std template about your type | see below |
| `: std::formatter<std::string>` | inherit string formatting, so width/align specs work for free | `std::format("[{:>8}]", Temp{1.5})` → `"[    1.5C]"` |

```cpp
struct Temp { double c; };

template <>
struct std::formatter<Temp> : std::formatter<std::string> {
    auto format(const Temp& t, std::format_context& ctx) const {
        return std::formatter<std::string>::format(std::format("{}C", t.c), ctx);
    }
};
// std::format("{}", Temp{21.5}) == "21.5C"
```

## Your task
- `hex_and_binary(255)` → `0xff 11111111`
- `banner("ok")` → `***ok****` (centred in 9 with *)
- make `Point` formattable as `(x, y)`

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
