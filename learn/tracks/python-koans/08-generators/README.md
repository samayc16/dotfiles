# 08 · Generators and lazy iteration

## Why it matters
Generators produce values on demand, so you can process infinite streams or huge files in constant memory, and compose pipelines like shell pipes.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `yield v` | makes the function a generator: each `next()` runs it to the next `yield` | see below |
| `Iterator[int]` | return type of a generator function (`collections.abc`) | `def ticks() -> Iterator[int]:` |
| `next(it)` | pull one value from an iterator | `next(iter("ab"))` → `'a'` |
| `islice(it, n)` | the first `n` items of any iterable, lazily (`itertools`) | `list(islice("abcdef", 2))` → `['a', 'b']` |
| `yield from sub` | yield everything `sub` yields (handy for recursion) | `yield from range(3)` |
| `while True: yield ...` | an infinite generator is fine: callers only take what they need | |

```python
def countdown(n: int) -> Iterator[int]:
    while n > 0:
        yield n          # pauses here until the caller asks for the next value
        n -= 1

list(countdown(3))       # [3, 2, 1]
```

## Your task
Implement `fib`, `take`, `chunked`, `flatten_deep` and `running_total` as generators (use `yield`).

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
