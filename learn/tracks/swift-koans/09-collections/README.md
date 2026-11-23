# 09 · Collections and higher-order functions

## Why it matters
Swift's collection API turns most loops into readable pipelines, and compactMap/reduce(into:) are the idioms you'll see in every codebase.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `[K: V]`, `[:]` | dictionary type, empty dictionary | `var ages: [String: Int] = [:]` |
| `Character` | one character; `"abc".first` is a `Character?` | `let c: Character = "x"` |
| `.filter { }`, `.map { }` | keep matching elements / transform each one | `[1, 2, 3].map { $0 * 10 }` → `[10, 20, 30]` |
| `.compactMap { }` | map, then drop the `nil`s | `["4", "x"].compactMap { Double($0) }` → `[4.0]` |
| `.reduce(start, op)` | fold with a start value; operators are functions too | `[2, 3].reduce(1, *)` → `6` |
| `.reduce(into: start) { acc, x in … }` | fold by mutating an accumulator | see below |
| `dict[k, default: v]` | read with a fallback; `+=` / `.append` write back | `tally["x", default: 0] += 1` |
| `Dictionary(grouping: xs) { key }` | bucket elements by a computed key | `Dictionary(grouping: [1, 2, 3]) { $0 % 2 }` → `[1: [1, 3], 0: [2]]` |
| `zip(a, b)` | pair elements up; stops at the shorter one | `zip([1, 2], ["a"])` → `[(1, "a")]` |
| `.a { }.b { }` | chain calls; reads left to right | `xs.filter { … }.map { … }` |

```swift
let byLength = ["ox", "yak", "emu"].reduce(into: [Int: [String]]()) { acc, word in
    acc[word.count, default: []].append(word)
}
// [2: ["ox"], 3: ["yak", "emu"]]
```

## Your task
Implement each function as a pipeline, no `for` loops.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
