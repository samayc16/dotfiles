# 13 · Patterns: let-else, if-let chains, slices and @

## Why it matters
Patterns are everywhere in Rust: `let`, `match`, `if let`, function parameters. The newer forms remove most remaining nesting: let-else is the guard clause (`bind or bail`), let chains replace pyramids of `if let`, and slice patterns turn length checks plus indexing into a single readable line.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `let P = v else { … };` | let-else: bind if the pattern matches, otherwise run `else`, which must leave (`return`, `break`, `continue`, panic). Reach for it when `?` can't say what you need | `let Ok(n) = s.parse::<u8>() else { return Err(format!("bad age {s:?}")); };` |
| `{s:?}` | Debug formatting: a string in quotes, escapes visible | `format!("{:?}", "a\"b")` → `"a\"b"` with the quotes |
| `if let P = v && cond && let Q = w { }` | let chains (2024 edition): every pattern must match and every condition hold; bindings flow left to right | `if let Some(c) = s.chars().next() && c.is_uppercase() { … }` |
| `[]`, `[x]`, `[a, b]`, `[first, .., last]` | slice patterns: match on length and contents | `[cmd, args @ ..] => run(cmd, args)` |
| `n @ 1..=9` | bind the value while testing it against a pattern | `Some(n @ 100..) => n` |
| `S { field: literal, .. }` | match one field's value, ignore the rest | `Msg::Move { x: 0, .. } => "vertical"` |
| `65..` | a half-open range pattern: 65 and up | |
| `match *e` / `&user.email` | match through a reference without moving out of it | |
| `(Ok(a), Ok(b))` | require two results at once | |
| `c.to_ascii_uppercase()` | | |

## Your task
- `parse_point`: `"3,4"` → `Ok((3, 4))` (spaces allowed around the numbers); otherwise `Err("no comma in "3;4"")` or `Err("not two numbers: "3,x"")`, using let-else
- `shape`: `"empty"`, `"one: 7"`, `"two: 1 and 2"`, `"many: 1 … 9"` (first … last), using slice patterns
- `admin_contact`: the email of an admin whose address ends in `@corp.example`, using one if-let chain
- `describe`: `"A"` for shift+a, `"a"` without shift; `"click in corner"` at (0, 0), `"click at 3,4"`; `"scroll up 3"`, `"scroll down 2"`, `"still"` for 0

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
