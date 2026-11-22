# 13 · Actors and Sendable: data-race safety

## Why it matters
Data races are the nastiest concurrency bugs. Swift 6 rejects them at compile time; actors are the tool that makes shared mutable state safe. (Fun fact: the starter doesn't even compile: that's the point.)

## Your task
Make `BankAccount` an actor so 1,000 concurrent deposits add up exactly, and make `Transaction` Sendable so it can cross task boundaries.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
