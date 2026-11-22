# 03 · Enums with associated values

## Why it matters
Swift enums carry data per case, so one type can model 'a circle with a radius OR a rect with sides'. switch must be exhaustive, so adding a case shows you every place to update.

## Your task
- `Shape.area` for each case
- `Command(parsing:)` turns "go north" / "wait" into cases (nil otherwise)
- `Suit` lists all cases via `CaseIterable`

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
