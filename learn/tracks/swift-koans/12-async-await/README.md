# 12 · async/await, async let, task groups

## Why it matters
Structured concurrency runs work in parallel while guaranteeing child tasks finish (or are cancelled) before the parent returns: no forgotten background tasks.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `func f() async -> T` | f can pause while waiting (sleep, network) without blocking a thread | |
| `await f()` | call an async function; marks a point where it may pause | `let n = await slowSquare(3)` |
| `Task.sleep(for:)`, `Duration` | pause; durations look like `.milliseconds(100)`, `.seconds(1)` | `try? await Task.sleep(for: .seconds(1))` |
| `async let x = f()` | start `f` now, in parallel; `await x` later for the result | see below |
| `withTaskGroup(of: T.self) { group in … }` | run any number of child tasks returning `T`; returns the closure's result | see below |
| `group.addTask { … }` | start one child task | |
| `for await r in group` | collect results as they finish (in **finish** order, not start order) | |
| `for (i, x) in xs.enumerated()` | loop with an index; `(i, x)` unpacks a tuple | |
| `t.0`, `t.1`, `\.1` | tuple elements; `\.1` is a key path usable as a function | `[(1, "a")].map(\.1)` → `["a"]` |

```swift
func slowSquare(_ n: Int) async -> Int {
    try? await Task.sleep(for: .milliseconds(100))
    return n * n
}

func demo() async -> (Int, [Int]) {
    async let a = slowSquare(3)                  // both start immediately…
    async let b = slowSquare(4)
    let sum = await a + b                        // …so this takes ~100 ms, not 200

    let squares = await withTaskGroup(of: Int.self) { group in
        for n in [1, 2, 3] { group.addTask { await slowSquare(n) } }
        var out: [Int] = []
        for await s in group { out.append(s) }
        return out.sorted()
    }
    return (sum, squares)                        // (25, [1, 4, 9])
}
```

## Your task
`fetchBoth` and `fetchAll` must run their fetches CONCURRENTLY (the checks time them) and keep results in input order.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
