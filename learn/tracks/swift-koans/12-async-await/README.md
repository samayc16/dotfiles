# 12 · async/await, async let, task groups

## Why it matters
Structured concurrency runs work in parallel while guaranteeing child tasks finish (or are cancelled) before the parent returns: no forgotten background tasks.

## Your task
`fetchBoth` and `fetchAll` must run their fetches CONCURRENTLY (the checks time them) and keep results in input order.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
