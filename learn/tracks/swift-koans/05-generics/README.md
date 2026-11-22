# 05 · Generics and where clauses

## Why it matters
Generics let one implementation work for every type while staying fully type-checked. Constraints (`where`) say exactly what a type must support.

## Your task
- generic `Stack<Element>` with push/pop/peek/isEmpty/count
- `allEqual` for any collection of Equatable elements
- `largest` returns the max of a non-empty array of Comparable values, or nil

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
