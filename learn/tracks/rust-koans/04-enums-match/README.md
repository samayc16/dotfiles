# 04 · Enums and match: variants with data, Option

## Why it matters
Rust's enums are tagged unions that can't be read as the wrong variant, and `match` won't compile until every variant is handled. That replaces `std::variant` + `std::visit`, sentinel values, and null pointers: `Option<T>` is how Rust says 'maybe nothing', and the compiler makes you deal with the nothing.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `enum E { A, B(T), C { x: T } }` | a type that is exactly one of its variants; variants can carry data | `enum Msg { Quit, Move { x: i32, y: i32 }, Write(String) }` |
| `match v { P => e, … }` | must cover every case (checked); each arm is an expression | see below |
| `E::C { x, .. }`, `E::B(a)` | patterns that unpack a variant's data; `..` ignores the rest | `Msg::Move { x, .. } => x` |
| `A \| B => …` | one arm for several patterns | `'a' \| 'e' => true` |
| `1..=9 =>`, `_ =>` | inclusive range pattern; `_` matches anything | `0..=17 => "minor"` |
| `matches!(v, P)` | `true` if `v` matches the pattern | `matches!(m, Msg::Quit)` |
| `Option<T>` | `Some(x)` or `None` | `let nick: Option<&str> = None;` |
| `opt?` | in a function returning `Option`: the value inside, or return `None` right away (koan 05 does the same for errors) | `let top = queue.pop()?;` |
| `{ …; … }` as an arm | an arm can be a block of statements | |
| `v.last().copied()` | the last element as an `Option<T>` (`.last()` alone gives `Option<&T>`) | |
| `x.sqrt()`, `PI` | `f64` methods; `std::f64::consts::PI` | `2.0_f64.sqrt()` |
| `format!("{n}")` | variables can go right inside `{}` | `format!("Bye, {name}.")` |

```rust
fn weight(msg: &Msg) -> i32 {
    match msg {
        Msg::Quit => 0,
        Msg::Move { x, y } => x * y,
        Msg::Write(text) => text.len() as i32,
    }
}
```

## Your task
- `Shape::area` for all three variants (the triangle uses Heron's formula, given in the doc comment) and `Shape::is_round`
- `size_word`: `"negative"`, `"zero"`, `"small"` (1 to 9) or `"large"`, with one `match` on ranges
- `run`: execute a tiny stack program and return the value left on top, or `None` on stack underflow or an empty stack
- `greet`: `"Hi, Ada!"` for `Some("Ada")`, `"Hi, stranger!"` for `None`

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
