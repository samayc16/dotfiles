# 10 · Decorators

## Why it matters
Decorators wrap behaviour (caching, retries, timing, auth) around functions without touching their bodies. They're everywhere: @dataclass, @cache, @pytest.fixture, Flask routes.

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
