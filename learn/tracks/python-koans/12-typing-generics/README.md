# 12 · Typing: generics (PEP 695), Protocol, TypedDict

## Why it matters
Type hints power your LSP: completion, go-to-definition and error squiggles before you run anything. Protocols give you duck typing that the type checker understands.

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
