# 11 · Codable: JSON in and out

## Why it matters
Codable turns JSON (APIs, config files) into typed Swift values and back with almost no code, and the compiler checks it.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `: Codable` | conform and Swift writes the JSON encode/decode code for you | `struct Pet: Codable { let name: String }` |
| `enum E: String { case a = "x" }` | raw-value enum: each case has a String (default: its own name) | `Theme.dark.rawValue` → `"dark_mode"` |
| `enum CodingKeys: String, CodingKey` | nested enum listing every property; raw values are the JSON key names | see below |
| `JSONDecoder().decode(T.self, from: data)` | JSON bytes → a `T` (throws on bad JSON) | |
| `T.self` | the type itself, passed as a value | `[Pet].self` |
| `JSONEncoder().encode(x)` | a value → JSON bytes (`Data`, throws) | |
| `Data(text.utf8)` | a String's bytes | |
| `#"…"#` | raw string: quotes and `\` need no escaping (used in `main.swift`) | `#"{"a": 1}"#` |

```swift
import Foundation

struct Pet: Codable {
    let name: String
    let birthYear: Int
    enum CodingKeys: String, CodingKey {
        case name
        case birthYear = "birth_year"            // the JSON says birth_year
    }
}
let json = #"{"name": "Rex", "birth_year": 2020}"#
let pet = try JSONDecoder().decode(Pet.self, from: Data(json.utf8))   // pet.birthYear == 2020
```

## Your task
Make `Todo` Codable with `isDone` mapped to the JSON key `is_done`, then implement `decodeTodos` and `roundTrip`.

Edit `Koan.swift` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows a symbol's type and docs (sourcekit-lsp)
- `grd` jumps to definitions (even into the standard library interface)
- `gra` code actions; `]d` next diagnostic: Swift 6 concurrency errors explain themselves
- `<leader>rr` runs the current file with `swift`
