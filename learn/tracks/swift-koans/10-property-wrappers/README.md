# 10 · Property wrappers

## Why it matters
Property wrappers package reusable get/set logic (clamping, validation, persistence). SwiftUI's @State and @Binding are property wrappers.

## Your task
Write `@Clamped(range)` so values assigned to the property are clamped into the range; `Volume.level` uses it with 0...10.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
