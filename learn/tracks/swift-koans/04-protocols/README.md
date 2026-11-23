# 04 · Protocols and extensions

## Why it matters
Swift is 'protocol-oriented': shared behaviour comes from protocols + extensions rather than class inheritance, and works for structs and enums too.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `protocol P { … }` | a list of requirements (like a Python `Protocol` or C++ concept) | `protocol Priced { var cents: Int { get } }` |
| `var x: T { get }` | requirement: a readable property (stored or computed) | |
| `struct S: P` | S promises to meet P's requirements | `struct Mug: Priced` |
| `extension T { … }` | add methods / computed properties to any type, even `Int` | `extension String { var shouted: String { uppercased() } }` |
| `extension P { … }` | default implementation every conforming type gets for free | see below |
| `{ expr }` body | a one-expression body returns `expr`, no `return` needed | `var cents: Int { 250 }` |
| `self` in an extension | the value the member was called on | `extension Int { var squared: Int { self * self } }` |
| `some P` | "some concrete type conforming to P" (used in `main.swift`) | `func show(_ x: some Priced)` |
| `.uppercased()`, `+` | uppercase a String, join Strings | `"ok".uppercased() + "?"` → `"OK?"` |

```swift
protocol Priced { var cents: Int { get } }

extension Priced {                               // every Priced type gets this
    func priceTag() -> String { "$\(cents / 100)" }
}

struct Mug: Priced {
    let size: Int
    var cents: Int { size * 100 }                // meets the requirement
}
// Mug(size: 3).priceTag() == "$3"
```

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
