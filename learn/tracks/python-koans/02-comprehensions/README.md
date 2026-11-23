# 02 · Comprehensions

## Why it matters
Comprehensions replace most for-loops that build a collection. They are shorter, faster, and make intent obvious: 'a list of X for each Y where Z'.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `[expr for x in xs if cond]` | list comprehension; the filter goes last | `[c.upper() for c in "abc" if c != "b"]` → `['A', 'C']` |
| `{k: v for x in xs}` | dict comprehension | `{n: n % 3 for n in (4, 5)}` → `{4: 1, 5: 2}` |
| `{expr for x in xs}` | set comprehension: duplicates vanish | `{len(w) for w in ["ab", "cd", "e"]}` → `{1, 2}` |
| `[y for a in outer for y in a]` | several `for`s read left → right, like nested loops (outer first) | `[(r, c) for r in "ab" for c in "12"]` → `[('a', '1'), ('a', '2'), ('b', '1'), ('b', '2')]` |
| `f(*xs)` | `*` spreads a list into separate arguments | `list(zip(*[("a", 1), ("b", 2)]))` → `[('a', 'b'), (1, 2)]` |
| `list[int]`, `dict[str, int]`, `set[str]` | built-in generic type hints (3.9+), no `typing.List` needed | `def ids() -> set[int]: ...` |

## Your task
Implement each function as a single comprehension (no explicit for-loop statements).

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
