# 03 · Lambdas, sorting and higher-order functions

## Why it matters
Functions are values in Python. Passing small lambdas as `key=` is the idiomatic way to sort, group, min/max by anything.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `lambda args: expr` | anonymous one-expression function | `lambda s: s.strip()` |
| `key=f` | `sorted` / `min` / `max` compare `f(item)` instead of the item | `max(["ox", "zebra"], key=len)` → `'zebra'` |
| tuple key | tuples compare element by element → sort by several fields | `sorted(pts, key=lambda p: (p.y, p.x))` (y, then x) |
| `sorted(xs)` vs `xs.sort()` | `sorted` returns a NEW list; `.sort()` mutates in place and returns `None` | |
| `reverse=True` | largest first | `sorted([3, 1, 2], reverse=True)` → `[3, 2, 1]` |
| closure | an inner function / lambda remembers the variables of the call that made it | `def adder(k): return lambda x: x + k` → `adder(5)(1)` → `6` |
| `Callable[[A, B], R]` | "a function taking A and B, returning R" (`collections.abc`) | `Callable[[str], bool]` |
| `def f[T](xs: Iterable[T]) -> list[T]` | PEP 695 generic function (3.12+): `T` is a type variable, same type in and out | `def last[T](xs: list[T]) -> T: return xs[-1]` |

## Your task
- sort people by age, then name
- `make_multiplier(n)` returns a function
- `apply_all` calls each function on x
- `top_n_by(items, n, key)` returns the n largest by key

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
