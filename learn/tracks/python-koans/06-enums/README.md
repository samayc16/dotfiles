# 06 · Enums

## Why it matters
Enums turn magic strings and numbers into named, typo-proof constants that your editor can autocomplete and your type checker can verify.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `class C(Enum): A = 1` | an enum: a fixed set of named members | `Suit.HEARTS` |
| `auto()` | let Python pick the value (1, 2, 3, ...) | `HEARTS = auto()` |
| `.name`, `.value`, `for m in C` | member name, member value, iterate in definition order | `Suit.HEARTS.name` → `'HEARTS'` |
| `C(value)` | look a member up by its value | `Suit(1)` → `Suit.HEARTS` |
| `is` | members are singletons: compare with `is` | `s is Suit.SPADES` |
| methods | define them like on any class; `self` is the member | `def is_red(self) -> bool: ...` |
| `IntEnum` | members are also `int`s, so they compare with numbers | `Prio.HIGH > 2` → `True` |
| `StrEnum` (3.11+) | members are also `str`s; `f"{m}"` gives the value | `f"{Mode.READ}"` → `'r'` |

## Your task
- `Color` with RED/GREEN/BLUE and `complement()` (RED↔GREEN, BLUE↔BLUE)
- `Level` is an IntEnum DEBUG=10 INFO=20 ERROR=40
- `Status` is a StrEnum TODO='todo' DONE='done'

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
