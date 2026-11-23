# 04 · Dataclasses

## Why it matters
Dataclasses generate __init__, __repr__ and __eq__ (and optionally ordering) from type-annotated fields. They are the standard way to model plain data in modern Python.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `@dataclass` | generates `__init__`, `__repr__`, `__eq__` from the annotated class attributes | see below |
| `name: type = default` (in the class body) | one field; field order = `__init__` argument order | `label: str = ""` |
| `field(default_factory=list)` | a fresh default per instance (`= []` would be shared, so dataclasses refuse it) | `seen: set[str] = field(default_factory=set)` |
| `def __post_init__(self)` | runs right after the generated `__init__`: validate or derive fields | |
| `@dataclass(order=True)` | adds `<` `<=` `>` `>=`, comparing fields as a tuple in declaration order | |
| `@classmethod` + `cls(...)` | alternative constructor; `cls` is the class itself | `Temp.from_text("21.5C")` |
| `from __future__ import annotations` | lets a method's hints name its own class (`-> Temp`) before it exists (3.14 does this by default) | |

```python
@dataclass(order=True)
class Temp:
    celsius: float
    label: str = ""
    readings: list[float] = field(default_factory=list)

    def __post_init__(self) -> None:
        if self.celsius < -273.15:
            raise ValueError("below absolute zero")

    @classmethod
    def from_text(cls, text: str) -> Temp:      # "21.5C" -> Temp(celsius=21.5, ...)
        return cls(float(text.removesuffix("C")))
```

## Your task
- Turn `Item` into a dataclass with a per-instance `tags` list and price validation
- Make `Version` an ordered dataclass with a `parse('1.2.3')` classmethod

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
