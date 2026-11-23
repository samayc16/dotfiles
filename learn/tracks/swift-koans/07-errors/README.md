# 07 · Error handling and typed throws

## Why it matters
Swift errors are explicit: a throwing call must be marked with try. Swift 6's typed throws let the compiler know exactly which errors can come out.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `enum E: Error` | an error type: any type conforming to `Error` can be thrown | `enum PinError: Error { case tooShort }` |
| `func f() throws -> T` | f may throw any `Error` | |
| `func f() throws(E) -> T` | typed throws (Swift 6): f can only throw an `E` | see below |
| `throw .tooShort` | stop and throw (the type is inferred from `throws(E)`) | |
| `try f()` | required in front of every call that can throw | `let pin = try checkPin("1234")` |
| `try? f()` | a throw becomes `nil`; the result is optional | `try? checkPin("12")` → `nil` |
| `do { … } catch { … }` | run throwing code; inside `catch`, `error` is what was thrown | see below |
| `!cond` | logical NOT (not the same as force-unwrap `x!`) | `guard !name.isEmpty else { … }` |

```swift
enum PinError: Error { case tooShort, notDigits(String) }

func checkPin(_ pin: String) throws(PinError) -> String {
    guard pin.count >= 4 else { throw .tooShort }
    guard Int(pin) != nil else { throw .notDigits(pin) }
    return pin
}

do {
    print("ok \(try checkPin("12"))")
} catch {                                  // typed throws: `error` is a PinError
    switch error {
    case .tooShort: print("too short")
    case .notDigits(let raw): print("\(raw)?")
    }
}
```

## Your task
- `parseAge` throws `.empty`, `.notANumber(text)` or `.outOfRange(n)` (valid: 0...150), using typed throws
- `ageOrNil` uses `try?`
- `message(for:)` turns the result into a friendly string with do/catch

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
