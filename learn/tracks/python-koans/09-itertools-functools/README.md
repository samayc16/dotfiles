# 09 · itertools & functools

## Why it matters
The standard library already has the loops you keep rewriting. Knowing itertools/functools makes code shorter and usually faster.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `groupby(xs, key=f)` | `(key, group)` pairs for runs of **adjacent** items with equal `f(x)`: sort first | `[(k, len(list(g))) for k, g in groupby("aabccc")]` → `[('a', 2), ('b', 1), ('c', 3)]` |
| `pairwise(xs)` (3.10+) | overlapping neighbours | `list(pairwise("abc"))` → `[('a', 'b'), ('b', 'c')]` |
| `accumulate(xs, fn)` | running results (default `fn` is `+`) | `list(accumulate([3, 1, 4], max))` → `[3, 3, 4]` |
| `reduce(fn, xs, start)` | fold a list into one value; `start` is the result for `[]` | `reduce(operator.add, ["a", "b"], "")` → `'ab'` |
| `operator.mul`, `operator.add` | operators as plain functions | `operator.mul(3, 4)` → `12` |
| `@cache` | memoize by arguments; adds `.cache_info()` | see below |
| `partial(fn, kw=v)` | pre-fill some arguments → a new callable | `parse_bin = partial(int, base=2)`; `parse_bin("101")` → `5` |

```python
@cache
def slow_square(n: int) -> int:
    time.sleep(1)
    return n * n

slow_square(4), slow_square(4)   # the second call is instant
```

## Your task
Use itertools/functools (no hand-written loops) for each function. `fib_memo(80)` must be instant.

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
