# 05 · Immutable data: frozen dataclasses, slots, replace()

## Why it matters
Immutable values can't be changed behind your back, can be dict keys/set members, and are safe to share. Producing a new copy instead of mutating is a habit that removes whole classes of bugs.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `@dataclass(frozen=True)` | assigning a field raises `FrozenInstanceError`; instances become hashable (set members, dict keys) | `len({Temp(1), Temp(1)})` → `1` |
| `slots=True` | fields live in `__slots__`: no per-instance `__dict__`, less memory, no stray attributes | `hasattr(t, "__dict__")` → `False` |
| `replace(obj, f=v)` | copy with some fields changed; the original is untouched (`dataclasses`) | `replace(Temp(1, "a"), label="b")` |
| `tuple[str, ...]` | a tuple of any length, all `str` (the `...` is literal syntax) | `flags: tuple[str, ...] = ()` |
| `(*t, x)` | a NEW tuple: everything in `t`, then `x` | `(*(1, 2), 3)` → `(1, 2, 3)` |

## Your task
- `Point` is frozen, slotted, and `moved()` returns a NEW point
- `Inventory.added()` returns a new inventory, leaving the original untouched

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
