# 10 · Property wrappers

## Why it matters
Property wrappers package reusable get/set logic (clamping, validation, persistence). SwiftUI's @State and @Binding are property wrappers.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `@propertyWrapper struct W` | a type that controls how a property is stored, read and written | |
| `var wrappedValue: T` | required: the value users of the property see | |
| `get { } set { }` | computed property with a setter; `newValue` is what was assigned | see below |
| `init(wrappedValue: T, …)` | receives the property's initial value (`= v`) plus your own arguments | |
| `@W(args) var x: T = v` | apply a wrapper: Swift calls `W(wrappedValue: v, args)` | `@Lowercased var email: String = "A@B.COM"` |
| `ClosedRange<T>`, `.lowerBound`, `.upperBound` | the type of `a...b` and its two ends | `(1...6).upperBound` → `6` |
| `min(a, b)`, `max(a, b)` | the smaller / larger of two values | `max(-2, 0)` → `0` |
| `static func`, `Self.f()` | a type-level helper (no instance needed); `Self` = this type | |
| `projectedValue` | optional extra exposed as `$x` (SwiftUI's `$binding`); not needed here | |

```swift
@propertyWrapper
struct Lowercased {
    private var text = ""
    init(wrappedValue: String) { text = wrappedValue.lowercased() }
    var wrappedValue: String {
        get { text }
        set { text = newValue.lowercased() }      // runs on every assignment
    }
}

struct Login { @Lowercased var email: String = "A@B.COM" }   // reads back "a@b.com"
```

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
