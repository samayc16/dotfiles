# 02 · Structs vs classes: value and reference semantics

## Why it matters
Choosing struct vs class decides whether assignment copies or shares. Swift defaults to structs (value types) because copies can't be mutated behind your back.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `struct Name { … }` | value type: assigning or passing it makes a **copy** | `var b = a` → two separate values |
| `class Name { … }` | reference type: assigning shares the **same** object | `let r2 = r1` → one object, two names |
| `final class` | a class that can't be subclassed (the usual choice) | `final class Logger { }` |
| `var hits = 0` in a type | stored property with a default; type inferred | |
| `func name() { … }` in a type | a method; call it as `value.name()` | `meter.reset()` |
| `mutating func` | a struct method that changes the struct's own properties | see below |
| `init(…) { self.x = x }` | initializer; `self` is the instance being built | see below |
| `a === b` | identity: the very same class instance? (`==` compares values) | `l1 === l2` → `true` |
| `x += 1` | add and assign | `hits += 1` |

```swift
struct Tally {
    var hits = 0
    mutating func hit() { hits += 1 }      // without `mutating`: "'self' is immutable"
}

final class Lamp {
    var watts: Int
    init(watts: Int) { self.watts = watts }   // self.watts = property, watts = parameter
}

var t1 = Tally(); var t2 = t1; t2.hit()        // t1.hits == 0, t2.hits == 1
let l1 = Lamp(watts: 40); let l2 = l1
l2.watts = 60                                  // l1.watts == 60 too: same object
```

## Your task
Make `Counter` a value type (struct with a `mutating` increment) so copies are independent; keep `Account` a class so copies are shared.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
