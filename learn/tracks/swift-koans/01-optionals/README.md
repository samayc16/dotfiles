# 01 · Optionals: if let, guard, ??, optional chaining

## Why it matters
Optionals make 'might be missing' part of the type, so the compiler forces you to handle nil. Most Swift crashes come from force-unwrapping (!) instead.

## Your task
Implement `greet`, `firstEven`, `parsePort` and `streetLength` without using `!`.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
