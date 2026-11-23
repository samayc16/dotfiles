# 12 · Typing: generics (PEP 695), Protocol, TypedDict

## Why it matters
Type hints power your LSP: completion, go-to-definition and error squiggles before you run anything. Protocols give you duck typing that the type checker understands.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `class Box[T]:` | PEP 695 generic class (3.12+): `T` is a type parameter | `b: Box[int] = Box()` |
| `self._items: list[T] = []` | annotate an attribute where you create it | |
| `__len__`, `__bool__` | make `len(obj)` and `if obj:` work | `def __bool__(self) -> bool: return self.count > 0` |
| `T \| None` | union: a `T` or `None` (3.10+) | `def find(...) -> int \| None:` |
| `Sequence[T]` | anything indexable with a length: list, tuple, str (`collections.abc`) | `def mid[T](xs: Sequence[T]) -> T:` |
| `class P(Protocol)` | structural interface: any class with matching methods fits, no inheritance | see below |
| `@runtime_checkable` | lets `isinstance(x, P)` check a Protocol at runtime (method names only) | |
| `class D(TypedDict)` | type for a plain dict with fixed keys; at runtime it's just a `dict` | see below |

```python
@runtime_checkable
class Named(Protocol):
    def name(self) -> str: ...          # `...` = no body, just the signature

class Dog:
    def name(self) -> str: return "rex"

isinstance(Dog(), Named)                # True: Dog never mentions Named

class Pixel(TypedDict):
    x: int
    y: int

p: Pixel = {"x": 1, "y": 2}
```

## Your task
- generic `Stack[T]` with push/pop/peek, len() and truthiness
- `first[T]` returns the first element or None
- `HasArea` protocol + `total_area`
- `Movie` TypedDict and `make_movie`

Tip: hover with `K` on `Stack[int]` and watch basedpyright infer types.

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
