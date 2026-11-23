# 05 · Generics and where clauses

## Why it matters
Generics let one implementation work for every type while staying fully type-checked. Constraints (`where`) say exactly what a type must support.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `struct Box<T> { … }` | generic type: `T` is a placeholder, filled in where it's used | `Box<Int>`, `Queue<String>()` |
| `func f<T>(_ x: T)` | generic function | `func twice<T>(_ x: T) -> [T] { [x, x] }` |
| `<T: Comparable>` | constraint: T must support `<`, `>`, `max()`… | `func smaller<T: Comparable>(_ a: T, _ b: T) -> T` |
| `Collection`, `C.Element` | protocol for arrays, strings, sets…; `C.Element` is its element type | `"abc"` is a Collection of `Character` |
| `where C.Element: Equatable` | extra constraint written after the signature | see below |
| `private var` | visible only inside this type | `private var log: [String] = []` |
| `[T] = []`, `[Int]()` | empty arrays (the element type must be known) | |
| array API | `.append(x)`, `.popLast()` → `T?`, `.first`/`.last` → `T?`, `.isEmpty`, `.count`, `.max()` → `T?`, `.allSatisfy { }` | `[2, 4].allSatisfy { $0 % 2 == 0 }` → `true` |

```swift
struct Queue<Item> {
    private var items: [Item] = []
    mutating func enqueue(_ item: Item) { items.append(item) }
    var front: Item? { items.first }
}

func startsWithSame<C: Collection>(_ a: C, _ b: C) -> Bool where C.Element: Equatable {
    a.first == b.first                           // startsWithSame("vim", "vi") == true
}
```

## Your task
- generic `Stack<Element>` with push/pop/peek/isEmpty/count
- `allEqual` for any collection of Equatable elements
- `largest` returns the max of a non-empty array of Comparable values, or nil

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
