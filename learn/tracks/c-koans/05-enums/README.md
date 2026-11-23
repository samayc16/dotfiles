# 05 · Enums with a fixed underlying type + switch

## Why it matters
Enums give names to states. C23's fixed underlying type makes their size and layout predictable, which matters for packed structs, file formats and hardware registers.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `enum E { A, B, C };` | named integer constants, numbered 0, 1, 2… | `enum Suit { CLUBS, HEARTS };` |
| `enum E : T { ... }` | C23: choose the underlying integer type, which fixes `sizeof(enum E)` | `enum Level : uint16_t { LOW, HIGH };` → size 2 |
| `(enum E)(expr)` | cast an integer back to the enum type | `(enum Suit)(s + 1)` |
| `(i + k) % n` | wrap-around: cycles through 0 … n-1 | `(3 + 1) % 4` → `0` |
| `switch (x) { case A: ... }` | jump to the matching `case`; `return` ends it (otherwise use `break`, or it falls through). Without a `default:`, `-Wall` warns about an enum case you forgot | see below |

```c
const char *suit_symbol(enum Suit s) {
    switch (s) {
    case CLUBS:  return "♣";
    case HEARTS: return "♥";
    }
    return "?";  // only for invalid values, but the compiler wants a return
}
```

## Your task
- declare `enum Dir : unsigned char` with NORTH, EAST, SOUTH, WEST
- `turn_right`, `opposite`, and `dir_name` (use a switch)

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
