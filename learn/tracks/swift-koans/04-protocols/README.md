# 04 · Protocols and extensions

## Why it matters
Swift is 'protocol-oriented': shared behaviour comes from protocols + extensions rather than class inheritance, and works for structs and enums too.

## Your task
- `Book` conforms to `Describable`
- give every `Describable` a default `shout()` via an extension
- add `isEven` to `Int` via an extension

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
