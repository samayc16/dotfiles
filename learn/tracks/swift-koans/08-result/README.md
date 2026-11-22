# 08 · The Result type

## Why it matters
Result packages 'value or error' as a value you can store, pass around and transform: handy for callbacks and for code that collects errors instead of stopping at the first.

## Your task
- `divide` returns `.failure(.divisionByZero)` for zero
- `divideTwice` chains with `flatMap`
- `describe` renders a Result

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
