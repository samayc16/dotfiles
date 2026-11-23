# 02 · Borrowing: &, &mut and slices

## Why it matters
A reference is a pointer the compiler can prove valid: it can't dangle, and the aliasing rule (many readers OR one writer, never both) rules out iterator invalidation and data races at compile time. Slices (`&[T]`, `&str`) are the idiomatic way to pass 'some contiguous data' without copying it, like `std::span` and `std::string_view` but checked.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `&v` | shared borrow: read-only, any number at once | `print_all(&names)` |
| `&mut v` | exclusive borrow: may modify; nothing else may borrow `v` meanwhile | `sort_desc(&mut scores)` |
| `&[T]` | a slice: pointer + length into a Vec, an array, or part of one | `fn mean(xs: &[f64]) -> f64` |
| `&v[a..b]`, `&v[..b]`, `&v[a..]` | sub-slice; `a` inclusive, `b` exclusive (bounds-checked) | `&bytes[2..6]` |
| `&str` | a string slice; a `"literal"` is a `&'static str` | `fn greet(name: &str)` |
| `for x in xs` (xs: `&[T]`) | iterates by reference: each `x` is a `&T` | `for p in prices { total += p; }` |
| `for x in xs.iter_mut()` | each `x` is a `&mut T`; write through it with `*x` | `for c in counts.iter_mut() { *c = 0; }` |
| `*x` | dereference: read or write through a reference | `*c += 1` |
| `s.find(' ')` | byte index of the first match, as `Option<usize>` | `"a=b".find('=')` → `Some(1)` |
| `opt.unwrap_or(d)` | the value inside, or `d` for `None` | `idx.unwrap_or(0)` |
| `while cond { }` | loop while true | |
| `line.to_string()` | an owned `String` copy of a `&str` | `"hi".to_string()` |

## Your task
- `sum`: add up a slice (the checks pass a `&Vec`, an array, and a sub-slice)
- `double_all`: double every element in place
- `first_word`: the text before the first space (all of `s` if there's none), as a slice *of `s`*: no allocation
- `trim_zeros`: the sub-slice without leading and trailing zeros
- `log_twice`: append two owned copies of `line` to `log`

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
