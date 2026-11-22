# 11 · Codable: JSON in and out

## Why it matters
Codable turns JSON (APIs, config files) into typed Swift values and back with almost no code, and the compiler checks it.

## Your task
Make `Todo` Codable with `isDone` mapped to the JSON key `is_done`, then implement `decodeTodos` and `roundTrip`.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
