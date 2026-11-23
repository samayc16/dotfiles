# 10 · Decorators

## Why it matters
Decorators wrap behaviour (caching, retries, timing, auth) around functions without touching their bodies. They're everywhere: @dataclass, @cache, @pytest.fixture, Flask routes.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `@deco` above `def f` | shorthand for `f = deco(f)` | |
| `*args, **kwargs` | accept / forward any positional and keyword arguments | `def log(*args, **kwargs): print(args, kwargs)` |
| `@wraps(fn)` | copy `__name__`, `__doc__`, ... from `fn` onto the wrapper (`functools`) | |
| function attributes | functions are objects: you can hang data on them | `wrapper.hits = 0` |
| `@deco(arg)` | decorator *factory*: `deco(arg)` runs first and must return the real decorator | see below |
| bare `raise` | inside `except`, re-raise the exception being handled | |

```python
def shout(fn):                          # plain decorator
    @wraps(fn)
    def wrapper(*args, **kwargs):
        return fn(*args, **kwargs).upper()
    return wrapper

def repeat(n):                          # factory: returns a decorator
    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            return [fn(*args, **kwargs) for _ in range(n)]
        return wrapper
    return decorator

@repeat(2)
@shout
def hi(name): return f"hi {name}"       # hi("bo") -> ['HI BO', 'HI BO']
```

## Your task
- `@count_calls` tracks `.calls` and keeps the wrapped function's name/docstring
- `@retry(times=n)` re-runs a failing function up to n times, then re-raises

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
