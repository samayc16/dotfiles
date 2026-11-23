# 01 · Optionals: if let, guard, ??, optional chaining

## Why it matters
Optionals make 'might be missing' part of the type, so the compiler forces you to handle nil. Most Swift crashes come from force-unwrapping (!) instead.

## Swift in 2 minutes

How to read a koan file (`Koan.swift`):

```swift
// a comment, like # in Python.   /* a block comment */
let rate = 0.2                    // constant: can never be reassigned (prefer let)
var total: Int = 0                // variable, with an explicit type annotation
total += 5

struct Point {                    // a small value type with two stored properties
    let x: Int
    let y: Int
}
let p = Point(x: 1, y: 2)         // structs get a free initializer with labels

func area(width: Int, height: Int) -> Int {   // labels, types, -> return type
    return width * height
}
let a = area(width: 3, height: 4)             // labels are written at the call → 12

func double(_ n: Int) -> Int { n * 2 }        // `_` = no label at the call site;
let d = double(21)                            // a one-expression body needs no return
print("p is (\(p.x), \(p.y))")                // \( ) interpolates, like f"{...}"
```

| Python | Swift | Note |
|---|---|---|
| `x = 1` (never changes) | `let x = 1` | the compiler nags if a `var` is never changed |
| `def f(a: int) -> int:` | `func f(a: Int) -> Int {` | types are capitalised; body in `{ }` |
| `f(a=3)` | `f(a: 3)` | labels are required unless declared `_` |
| `f"hi {name}"` | `"hi \(name)"` | |
| `None` | `nil` | only allowed in optional types (`String?`, below) |
| `list[int]`, `len(s)` | `[Int]`, `s.count` | |

**Running it:** `learn check` (or `<leader>lc`) compiles your `Koan.swift` with the read-only checks in `main.swift` (Swift 6 mode) and runs them. The text after `—` is what your code returned:

```
  ✗ greet with a name — Hello!
  ✓ streetLength nil chain

  1/6 checks passing
```

A compile error reads *file:line:column*, then the problem; fix the first one first:

```
Koan.swift:2:21: error: cannot convert value of type 'Int' to specified type 'String'
2 | let label: String = count
  |                     `- error: cannot convert value of type 'Int' to specified type 'String'
```

To experiment, put a few lines in a scratch `.swift` file and run it with `<leader>rr` (top-level code runs top to bottom).

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `T?` | optional: a `T` **or** `nil` | `var nickname: String? = nil` |
| `Int(text)` | text → number can fail, so it returns `Int?` | `Int("12")` → `12`, `Int("hi")` → `nil` |
| `a ?? b` | the value inside `a`, or `b` if `a` is `nil` | `nickname ?? "anon"` → `"anon"` |
| `if let x = opt { }` | run the block only if `opt` has a value, bound to `x` | see below |
| `guard let x = opt else { return … }` | exit early on `nil`; after it, `x` is a plain value | see below |
| `a?.b?.c` | optional chaining: the whole thing is `nil` at the first `nil` | `user?.name.count` is an `Int?` |
| `opt!` | force unwrap: crashes on `nil`. Banned in this koan | |
| `1...10`, `.contains(x)` | closed range (both ends included), membership test | `(1...10).contains(11)` → `false` |
| `{ $0 > 3 }` | a tiny inline function (closure); `$0` is its argument | `[1, 5, 2].first { $0 > 3 }` → `5` |
| `%` `==` `&&` `\|\|` `!` | remainder, equals, and, or, not | `7 % 3 == 1 && !false` → `true` |

```swift
func shoutName(_ name: String?) -> String {
    if let name {                                // short for `if let name = name`
        return name.uppercased()
    }
    return "NOBODY"
}

func parseEvenCount(_ text: String) -> Int? {
    guard let n = Int(text), n % 2 == 0 else { return nil }   // comma = "and also"
    return n                                                  // n is a plain Int here
}
```

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
