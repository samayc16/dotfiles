# 08 · The Result type

## Why it matters
Result packages 'value or error' as a value you can store, pass around and transform: handy for callbacks and for code that collects errors instead of stopping at the first.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `Result<Success, Failure>` | an enum: `.success(value)` or `.failure(error)` | `Result<Int, NetError>` |
| `.success(x)`, `.failure(e)` | build one; the type comes from the return type | `return .failure(.offline)` |
| `c ? a : b` | ternary: `a` if `c` is true, else `b` | `n > 0 ? "pos" : "neg"` |
| `r.map { }` | transform a success value; a failure passes through | `ping("a").map { $0 * 2 }` |
| `r.flatMap { }` | chain a step that itself returns a Result; first failure wins | see below |
| `r.get()` | success → value, failure → throws (so use `try`) | `try? ping("a").get()` → `42` |
| `switch` as a value | if every case is one expression, the switch is the function's result | see below |
| `case .failure(.timeout):` | nested pattern: a case inside a case | |

```swift
enum NetError: Error { case offline, timeout }

func ping(_ host: String) -> Result<Int, NetError> {
    host.isEmpty ? .failure(.offline) : .success(42)
}

let total = ping("a").flatMap { ms in ping("b").map { ms + $0 } }   // .success(84)

func show(_ r: Result<Int, NetError>) -> String {
    switch r {
    case .success(let ms): "\(ms) ms"
    case .failure(.offline): "offline"
    case .failure(.timeout): "timeout"
    }
}
```

## Your task
- `divide` returns `.failure(.divisionByZero)` for zero
- `divideTwice` chains with `flatMap`
- `describe` renders a Result

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
