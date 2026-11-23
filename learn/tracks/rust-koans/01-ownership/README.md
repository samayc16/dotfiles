# 01 · Ownership: moves, Copy and clone

## Why it matters
Ownership is the one idea everything else in Rust builds on. It's RAII made mandatory: every value has exactly one owner, and moving it (the default) leaves nothing behind to double-free or use after free. C++ moves leave a valid-but-unspecified husk; Rust's are destructive, and the compiler tracks every one.

## Rust in 2 minutes

**How a koan runs:** each exercise is a small Cargo project. Your code is the library crate in `src/lib.rs` (no `main`); `tests/checks.rs` uses it from the outside like any other crate would (`use koan::*;`). `learn check` builds both with cargo and runs every `#[test]` as one check:

```
  ✓ stash_moves_the_ticket_into_the_wallet
  ✗ take_last_moves_one_ticket_out — the ticket that was taken: expected Some(Ticket { seat: 9 }), got None
  ✗ split_rows_keeps_order — not implemented yet: replace the todo!() at src/lib.rs:23:5

  1/6 checks passing
```

`todo!()` compiles as any type and panics when it runs: replace each one.

**Compile errors** come first, and rustc's are unusually good: a code, the exact spot, *why*, and often the fix. Read the labels under the code:

```
error[E0382]: borrow of moved value: `names`
 --> src/lib.rs:4:20
  |
2 |     let kept = names;
  |                ----- value moved here
3 |
4 |     println!("{}", names.len());
  |                    ^^^^^ value borrowed here after move
```

`rustc --explain E0382` (`<leader>ce` in nvim) prints a whole page about any error code.

**From C/C++:**

| C / C++ | Rust | Note |
|---|---|---|
| `const auto x = 5;` | `let x = 5;` | immutable by default; type inferred |
| a variable that changes | `let mut x = 5;` | `mut` is opt-in, per binding |
| `int f(int a)` | `fn f(a: i32) -> i32` | types after names: `i32`, `u64`, `usize`, `f64`, `bool`, `char` |
| `return a + 1;` | `a + 1` | the last expression, **without** `;`, is the return value |
| `std::vector<T>` | `Vec<T>` | `vec![1, 2, 3]`, `.push(x)`, `.len()`, `v[i]` (bounds-checked) |
| `std::string` / `std::string_view` | `String` / `&str` | `String::from("hi")`, `"hi".to_string()` |
| `std::optional<T>` | `Option<T>` | `Some(x)` or `None`; there is no null |
| `auto b = std::move(a);` | `let b = a;` | moves are the default and *destructive*: `a` is gone, no moved-from husk |
| copy constructor | `.clone()` | deep copies are always explicit |
| trivially copyable struct | `#[derive(Clone, Copy)]` | then assignment copies, like an `int` |
| destructor | `impl Drop` | runs when the owner goes out of scope (RAII), exactly once |
| `printf("%d", x)` | `println!("{x} and {}", y)` | `!` marks a macro; `{:?}` prints anything that derives `Debug` |

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `let b = a;` | moves `a` into `b` (non-`Copy` types); using `a` afterwards is error E0382 | `let owner = names;` |
| `fn f(v: Vec<T>)` | `f` takes ownership: the caller's value is moved in | `fn shred(doc: String) {}` |
| `fn f(mut v: Vec<T>)` | the parameter is a mutable binding inside `f` | `fn sorted(mut v: Vec<i32>) -> Vec<i32>` |
| `v.pop()` | removes the last element and returns it (moved out) as `Option<T>` | `let top = stack.pop();` |
| `for x in v { }` | iterates **by value**: consumes `v`, each `x` is owned | `for word in words { shelf.push(word); }` |
| `(a, b)` | a tuple: return several values; unpack with `let (a, b) = …;` | `(min, max)` |
| `Point { x: 1, y: 2 }` | a struct literal; `p.x` reads a field | `Size { w: s.w * 2, h: s.h }` |
| `.clone()` | explicit deep copy | `let backup = draft.clone();` |
| `s.push_str("!")` | append to a `String` (needs `mut`) | `title.push_str(" II");` |
| `#[derive(Clone, Copy)]` | opt a small type into copy semantics | |
| `todo!()` | placeholder that panics when reached | |

## Your task
- `stash`: put the ticket into the wallet and hand the wallet back
- `take_last`: move the last ticket out; return what's left and the ticket (`None` if the wallet was empty)
- `split_rows`: seats below 100 go to the front row, the rest to the back, in order. `Ticket` can't be cloned, so move them
- `nudge`: return the point moved by (+1, +1)
- `photocopy`: return the original note and a clone with `" (copy)"` appended

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
