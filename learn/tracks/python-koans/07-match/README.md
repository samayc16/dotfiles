# 07 · Structural pattern matching

## Why it matters
match/case destructures data while it branches. It replaces chains of isinstance/len/key checks with patterns that read like the data's shape.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `match x:` / `case PATTERN:` | the first matching case runs; patterns check shape AND bind names | see below |
| `case _:` | wildcard, matches anything (the "else") | |
| `case Cls(attr=name)` | class pattern: `isinstance` check + bind the attribute | `case Point(x=0, y=y):` |
| `case Cls(a, b)` | positional class pattern; dataclasses define the order (`__match_args__`) | `case Point(x, y):` |
| `case P if cond:` | guard: the pattern must match AND `cond` be true | `case Point(x, y) if x == y:` |
| `case ["cmd", arg]` | sequence pattern: exact length, literals + captures | `case ["say", word]:` |
| `case ["cmd", *rest]` | `*rest` captures the remaining items as a list (possibly empty) | `case ["say", *words]:` |
| `case A \| B` | either pattern | `case ["help"] \| ["?"]:` |
| `case {"k": pattern}` | mapping pattern: those keys must exist (extra keys are ignored) | `case {"kind": "temp", "at": (h, m)}:` |
| `int(n)`, `str(s)` in a pattern | type check + capture | `case {"value": float(v)}:` |

```python
match reading:
    case {"kind": "temp", "value": float(v)} if v > 30:
        return f"hot {v}"
    case Point(x=0, y=y):
        return f"on the y axis at {y}"
    case ["say", *words]:
        return " ".join(words)
    case _:
        return "?"
```

## Your task
- `describe(shape)`: 'circle r=2', 'square 3', 'rect 2x5', or 'unknown'
- `handle(command)`: 'going north', 'taking sword, shield', 'bye', or 'what?'
- `on_event(event)`: 'click at 3,4', 'key q', or 'ignored'

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
