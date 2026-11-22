# 02 · Structs vs classes: value and reference semantics

## Why it matters
Choosing struct vs class decides whether assignment copies or shares. Swift defaults to structs (value types) because copies can't be mutated behind your back.

## Your task
Make `Counter` a value type (struct with a `mutating` increment) so copies are independent; keep `Account` a class so copies are shared.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
