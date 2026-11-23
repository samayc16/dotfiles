# 03 · Enums with associated values

## Why it matters
Swift enums carry data per case, so one type can model 'a circle with a radius OR a rect with sides'. switch must be exhaustive, so adding a case shows you every place to update.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `import Foundation` | Apple's base library (math, JSON, dates…) | |
| `enum E { case a, b }` | a type with a fixed set of cases | `enum Dir { case up, down }` |
| `case card(last4: String)` | associated value: a case can carry its own data | `Payment.card(last4: "1234")` |
| `.up` | leading dot: the type is inferred from context | `let d: Dir = .up` |
| `var x: T { … }` | computed property: code that runs on every read | see below |
| `switch v { case …: }` | must cover every case; no fall-through, no `break` | see below |
| `case .card(let n):` / `case let .split(a, b):` | bind the associated values to names | see below |
| `case let x where x < 0:` / `default:` | extra condition on a case / catch-all | |
| `init?(…)` | failable initializer: may `return nil` instead of a value | see below |
| `init?(parsing text: String)` | `parsing` is the call-site label, `text` the name inside | `Command(parsing: "x")` |
| `enum E: CaseIterable, Equatable` | conformances go after `:`. `CaseIterable` adds `E.allCases`; `Equatable` enables `==` | `Dir.allCases` → `[.up, .down]` |
| `.split(separator:)`, `String(sub)` | split text into `Substring`s; convert back to `String` | `"a-b".split(separator: "-")` → `["a", "b"]` |
| `Double.pi` | π | |

```swift
enum Payment {
    case cash
    case card(last4: String)
    case split(Int, Int)

    var label: String {                          // computed property
        switch self {
        case .cash: return "cash"
        case .card(let last4): return "card …\(last4)"
        case let .split(a, b): return "split \(a)/\(b)"
        }
    }

    init?(code: String) {                        // Payment(code: "?") == nil
        switch code {
        case "c": self = .cash                   // inside an enum init, pick the case
        default: return nil
        }
    }
}
```

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
