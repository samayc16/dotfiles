# 06 · Closures, capturing and @escaping

## Why it matters
Closures are everywhere in Swift: sorting, SwiftUI, async callbacks. Knowing when a closure captures state and when it 'escapes' the function is key to avoiding leaks and races.

## Your task
- `byLengthThenAlpha` sorts with a trailing closure
- `makeIncrementer(step:)` returns a closure keeping a running total
- `EventBus.on` stores handlers (needs `@escaping`), `emit` calls them all

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
