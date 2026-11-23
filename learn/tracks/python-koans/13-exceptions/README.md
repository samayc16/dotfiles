# 13 · Exceptions: hierarchies, chaining, ExceptionGroup

## Why it matters
Good error types make failures debuggable. `raise ... from` keeps the original cause in tracebacks; ExceptionGroup reports several failures at once (validation, concurrent tasks).

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `class E(Base): ...` | custom exception: subclass `Exception` or your own base | `class ConfigError(Exception): pass` |
| `super().__init__(msg)` | sets the message that `str(err)` shows | |
| `raise New(...) from err` | chaining: the original error is kept as `new.__cause__` and shown in the traceback | see below |
| `ExceptionGroup(msg, [errs])` | one exception carrying several (3.11+) | `ExceptionGroup("bad rows", [ValueError(1), ValueError(2)])` |
| `except* T as g:` | handle only the `T` members of a group; `g.exceptions` lists them | see below |
| inside `except*` | `return` / `break` / `continue` are not allowed: set a variable instead | |

```python
class ParseError(Exception):
    def __init__(self, line: int) -> None:
        super().__init__(f"bad line {line}")
        self.line = line

try:
    int("x")
except ValueError as err:
    raise ParseError(3) from err         # ParseError.__cause__ is the ValueError

try:
    raise ExceptionGroup("batch", [KeyError("a"), KeyError("b"), TypeError("c")])
except* KeyError as g:
    missing = len(g.exceptions)          # 2
except* TypeError:
    pass
```

## Your task
- `AppError` base + `NotFound(key)` subclass with a `.key` attribute
- `lookup` turns KeyError into NotFound, chained with `from`
- `validate_all` raises an ExceptionGroup of every invalid item
- `count_value_errors` uses `except*` to count ValueErrors in a group

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
