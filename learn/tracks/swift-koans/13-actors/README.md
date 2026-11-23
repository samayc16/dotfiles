# 13 · Actors and Sendable: data-race safety

## Why it matters
Data races are the nastiest concurrency bugs. Swift 6 rejects them at compile time; actors are the tool that makes shared mutable state safe. (Fun fact: the starter doesn't even compile: that's the point.)

## New syntax
The starter doesn't compile, on purpose. Swift 6 reports something like:

```
main.swift:7:31: error: non-Sendable type 'BankAccount' of let 'account' cannot exit main actor-isolated context
```

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `actor A { … }` | like a class, but only one task at a time may touch its state | `actor Scoreboard { var points = 0 }` |
| `await a.method()` | from outside, every actor call (and property read) may wait its turn | `await board.add(3)` |
| `private(set) var` | readable from outside, writable only inside the type | `private(set) var points = 0` |
| `: Sendable` | safe to pass between tasks (e.g. a struct of `let` Sendable fields) | `struct Move: Sendable { let x: Int }` |
| `0..<n` | half-open range: 0 up to n − 1 | `for i in 0..<3` → 0, 1, 2 |
| `try await` | call something that is both throwing and async | `try await vault.withdraw(5)` |
| `withTaskGroup(of: Void.self)` | a task group whose children return nothing | |

```swift
actor Scoreboard {
    private(set) var points = 0
    func add(_ n: Int) { points += n }           // inside the actor: no await
}

let board = Scoreboard()
await board.add(3)                               // outside: await
let now = await board.points                     // reads await too
```

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
