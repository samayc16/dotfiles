# 01 · f-strings

## Why it matters
f-strings are how modern Python builds every string: logs, reports, CLI output. The format-spec mini-language (alignment, width, precision) saves you from manual padding.

## Python koans in 2 minutes

This track assumes everyday Python 3 (functions, lists/dicts, classes, `try`/`except`) and drills one
*modern* feature per koan. The checker uses `~/learn/.venv/bin/python` if it exists, else `python3`;
koans need Python 3.12+ (they use `def f[T]` generics).

| File | Role |
|---|---|
| `koan.py` (your workspace) | the only file you edit: replace each `raise NotImplementedError(...)` / `# TODO` |
| `test_koan.py` (next to this README) | read-only checks: open it to see the exact expected values |
| `_lib/harness.py` | runs every `test_*` function in order and prints ✓ / ✗ per check |

Run: `learn check` or `<leader>lc`. `<leader>rr` runs `koan.py` itself (handy with a quick `print`).

What the koan 01 starter prints:

```
  ✗ receipt line is aligned — got 'apple 3 x 1.5'
  ✗ percent has one decimal — not implemented yet: use the % format spec
  ✗ debug form — not implemented yet: f-strings have a debugging form

  0/3 checks passing
```

| After the dash | Means |
|---|---|
| `got ...` | your function returned something else; compare with `test_koan.py` |
| `not implemented yet: ...` | the stub is still there; its message is a mini-hint |
| `TypeError: ...` (any exception) | your code crashed; fix that first |

Every line ✓ (exit code 0) = pass.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `f"{expr:spec}"` | everything after the `:` is a *format spec* for that value | `f"{7:03}"` → `'007'` |
| `<` `>` `^` + width | left / right / centre align in that many columns | `f"[{'tea':>6}]"` → `'[   tea]'` |
| `.Nf` | fixed-point float with N decimals | `f"{3.14159:.3f}"` → `'3.142'` |
| align + width + `.Nf` | combine them, in that order | `f"[{2.5:>7.3f}]"` → `'[  2.500]'` |
| `.N%` | ×100, add `%`, N decimals | `f"{0.5:.0%}"` → `'50%'` |
| `{expr=}` | self-documenting: the expression's text, `=`, then its repr | `name = "ada"; f"{name=}"` → `"name='ada'"` |
| `{expr!r}` | use `repr()` instead of `str()` (the tests use it to show quotes) | `f"{'hi'!r}"` → `"'hi'"` |

Full spec order: `[fill][align][sign][width][,][.precision][type]`, e.g. `f"{1234.5:*>10,.1f}"` → `'***1,234.5'`.
Offline reference: `python3 -m pydoc FORMATTING`.

## Your task
- `receipt_line` pads the item to 12 chars (left), qty to 3 (right), price to 8 with 2 decimals (right)
- `percent` renders a ratio as a percentage with one decimal
- `debug_expr` returns the `x=` self-documenting form

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
