# 07 · Error handling and typed throws

## Why it matters
Swift errors are explicit: a throwing call must be marked with try. Swift 6's typed throws let the compiler know exactly which errors can come out.

## Your task
- `parseAge` throws `.empty`, `.notANumber(text)` or `.outOfRange(n)` (valid: 0...150), using typed throws
- `ageOrNil` uses `try?`
- `message(for:)` turns the result into a friendly string with do/catch

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
