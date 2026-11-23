# 12 · Memory layout, padding and static_assert

## Why it matters
Struct layout decides memory use, cache behaviour, and whether your struct matches a file format, network packet or hardware register map. static_assert turns layout assumptions into compile errors.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `static_assert(cond, "msg")` | C23 keyword, checked at COMPILE time: the build fails with `msg` if `cond` is false (msg optional) | `static_assert(sizeof(int) == 4);` |
| `sizeof(T)` | bytes a type occupies, padding included | `sizeof(struct Mixed)` → `16` |
| `alignof(T)` | C23 keyword: the address multiple `T` must start at | `alignof(double)` → `8` |
| `offsetof(T, f)` | `<stddef.h>`: byte offset of field `f` inside struct `T` | `offsetof(struct Mixed, d)` → `8` |
| padding | unused bytes the compiler inserts so each field starts at a multiple of its alignment; the total is rounded up to the largest alignment | see below |

```c
struct Mixed  { char c; double d; };                 // c@0, 7 pad, d@8      → 16 bytes
struct Sorted { double d; char c; };                 // d@0, c@8, 7 tail pad → 16 bytes (!)
struct Tight  { double d; int32_t i; char tag[4]; }; // 8 + 4 + 4, no padding → 16 bytes
```

## Your task
Reorder the fields of `struct Packet` (don't change their types) so it packs into 8 bytes. The check fails to COMPILE until you do: read the static_assert message.

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
