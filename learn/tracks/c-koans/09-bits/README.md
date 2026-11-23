# 09 · Bit manipulation

## Why it matters
Hardware registers, protocols, flags, hashes and compression all live at the bit level. If you touch Verilog, this is the software side of the same thinking.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `uint32_t` etc. | `<stdint.h>` exact-width integers: `uint8_t`, `int16_t`, `uint64_t`… | `uint16_t port = 8080;` |
| `&` `\|` `^` `~` | bitwise AND, OR, XOR, NOT | `0b1100 & 0b1010` → `0b1000` |
| `<<`, `>>` | shift left / right; `1u << k` is a mask with only bit `k` set | `1u << 4` → `16` (`0b1'0000`) |
| `UINT32_C(1)` | the constant 1 with a 32-bit unsigned type (a bare `1` is a signed `int`, and `1 << 31` is UB) | `UINT64_C(1) << 40` |
| `(1u << w) - 1` | a mask of the lowest `w` bits | `(1u << 3) - 1` → `0b111` |
| `0x...`, `%X` | hex literal; print in hex | `printf("0x%X", 255u)` → `0xFF` |
| `unsigned` | short for `unsigned int` | `unsigned shift = 3;` |
| `stdc_count_ones` | C23's `<stdbit.h>` has popcount built in, but macOS's libc doesn't ship it yet, so you write your own | |

## Your task
Implement `is_power_of_two`, `set_bit`, `clear_bit`, `toggle_bit`, `popcount` and `extract_field`.

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
