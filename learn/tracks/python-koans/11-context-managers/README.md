# 11 · Context managers

## Why it matters
`with` guarantees cleanup (closing files, releasing locks, restoring state) even when exceptions fly. Writing your own is one decorator away.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `with cm as x:` | calls `cm.__enter__()`, binds its return value to `x`, runs the block, then ALWAYS calls `cm.__exit__(...)` | `with open(p) as f:` |
| `def __enter__(self)` | setup; its return value is the `as` target (usually `self`) | |
| `def __exit__(self, *exc_info)` | teardown; the args are `None` when there was no error; return a falsy value so exceptions propagate | |
| `time.perf_counter()` | high-resolution clock for durations, in seconds | `t0 = time.perf_counter()` |
| `@contextmanager` | write one as a generator: code before `yield` = enter, after = exit (`contextlib`) | see below |
| `try: yield ... finally:` | makes the "after" part run even if the `with` block raised | |
| `-> "Timer"` | string annotation: a forward reference to a class that isn't finished yet | |

```python
@contextmanager
def env_var(name: str, value: str) -> Iterator[None]:
    old = os.environ.get(name)
    os.environ[name] = value
    try:
        yield                      # the body of the `with` runs here
    finally:
        if old is None:
            del os.environ[name]
        else:
            os.environ[name] = old
```

## Your task
- `Timer` measures the time spent inside its `with` block in `.elapsed`
- `working_dir(path)` switches cwd and ALWAYS restores it, even on error

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
