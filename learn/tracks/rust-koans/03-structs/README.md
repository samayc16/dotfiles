# 03 · Structs and impl: methods, Self and private fields

## Why it matters
Rust has no classes, constructors or inheritance: data lives in structs, behaviour in `impl` blocks, and how a method takes `self` (`&self`, `&mut self`, or by value) says exactly what it does to the object. Privacy is per module, so a struct with private fields can guarantee invariants, like a class with private members but without the boilerplate.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `struct S { a: T }` | named fields, private to the module unless marked `pub` | `struct Song { title: String, secs: u32 }` |
| `impl S { … }` | methods and associated functions of `S` | |
| `fn new(…) -> Self` | associated function (no `self`), called as `S::new(…)`; `Self` is the type being implemented | `fn empty() -> Self { Self { items: Vec::new() } }` |
| `Self { a, b }` | field-init shorthand when variables are named like the fields | `Song { title, secs }` |
| `&self` | a method that reads (like a `const` member function) | `fn minutes(&self) -> u32 { self.secs / 60 }` |
| `&mut self` | a method that modifies | `fn skip(&mut self, s: u32) { self.secs += s; }` |
| `self` | a method that consumes the value (it's moved in) | `fn into_title(self) -> String { self.title }` |
| `const NAME: T = v;` in an `impl` | associated constant, used as `S::NAME` or `Self::NAME` | `const MAX_VOL: u8 = 11;` |
| `x.clamp(lo, hi)` | limit to a range | `130.clamp(0, 100)` → `100` |
| `format!(…)` | like `println!`, but returns a `String` | `format!("{} min", m)` |
| `if c { a } else { b }` | an expression: both branches produce a value | `let unit = if n == 1 { "item" } else { "items" };` |

## Your task
- `Rect::new` and `Rect::square` build rectangles; `area` and `can_hold` read; `scale` multiplies both sides in place
- `Thermostat` keeps its target within `MIN..=MAX` (10 to 30): clamp in `new` and in `adjust`
- `adjust` counts every call in `changes`; `target()` and `changes()` are getters for the private fields
- `report` consumes the thermostat and returns `"22°C after 1 change"` / `"25°C after 3 changes"`

Edit `src/lib.rs` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)
- The checks are ordinary Rust tests in `tests/checks.rs`: read them to see exactly what's expected. `cargo test` works in the workspace too (`learn check` always runs the original copy)

## Nvim tips
- `K` shows a symbol's type and docs (rust-analyzer); `grd` jumps to definitions, even into std's source
- `]d` next diagnostic · `<leader>ce` explains the error code (`rustc --explain`) · `<leader>cE` shows the full compiler message
- `gra` code actions: fill match arms, add missing fields or trait items, import a name
- `<leader>th` toggles inlay hints (inferred types, elided lifetimes) · `<leader>cm` expands a macro
- `<leader>rn` runs one check from `tests/checks.rs` (runnables) · `<leader>dn` debugs it
