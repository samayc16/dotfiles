# 06 · Closures, capturing and @escaping

## Why it matters
Closures are everywhere in Swift: sorting, SwiftUI, async callbacks. Knowing when a closure captures state and when it 'escapes' the function is key to avoiding leaks and races.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `{ (a: Int, b: Int) -> Bool in a < b }` | full closure: parameters, return type, `in`, body | |
| `{ a, b in a > b }` | same, types inferred from context | `nums.sorted { a, b in a > b }` |
| `$0`, `$1` | shorthand for the 1st / 2nd argument | `nums.sorted { $0 > $1 }` |
| `f(x) { … }`, `f { … }` | trailing closure: a last closure argument goes after `)`; drop `()` if it's the only one | `alarm.add { print("beep") }` |
| `() -> Int`, `(String) -> Void` | function types: no args returning Int; String in, nothing out | `let ping: () -> Void = { print("ping") }` |
| `(a, b) < (c, d)` | tuples compare element by element, left to right | `(1, "z") < (2, "a")` → `true` |
| capturing | a closure keeps (and can change) the local `var`s it uses, even after the function returns | see below |
| `@escaping` | a closure parameter that is stored and called later must say so | see below |
| `for x in xs { }` | loop over a collection | `for w in words { print(w) }` |

```swift
func makeLogger() -> (String) -> [String] {
    var lines: [String] = []              // captured: lives on inside the closure
    return { line in
        lines.append(line)
        return lines
    }
}
let log = makeLogger()
_ = log("boot")                           // `_ =` ignores a result
log("ready")                              // ["boot", "ready"]

final class Alarm {
    private var actions: [() -> Void] = []
    func add(_ action: @escaping () -> Void) { actions.append(action) }   // stored → escaping
}
```

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
