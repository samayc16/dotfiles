# 10 · Lifetimes: saying which borrow a result comes from

## Why it matters
Every reference has a lifetime, and the borrow checker proves no reference outlives its data: that's how Rust rules out dangling pointers at compile time. Usually it infers them. When a function returns a reference and takes several, or a struct stores one, you say which borrow the result is tied to. Annotations never change how long anything lives; they describe relationships, so the compiler can check every caller.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `'a` | a lifetime: the region of code in which a borrow is valid | |
| `fn f<'a>(x: &'a str) -> &'a str` | the result borrows from `x`, so it can't outlive `x` | `fn trim_dots<'a>(s: &'a str) -> &'a str` |
| elision | one reference in: the output borrows from it. A `&self` method: from `self`. Anything else: you must say | `fn first(s: &str) -> &str` needs no `'a` |
| tie only one input | give a lifetime only to the input the result comes from | `fn pick<'a>(from: &'a [u8], key: &str) -> &'a [u8]` |
| `struct S<'a> { r: &'a str }` | a struct holding a borrow can't outlive what it borrows | `struct Token<'src> { text: &'src str }` |
| `impl<'a> S<'a> { … }` | methods for a struct with a lifetime | |
| `-> Option<&'a str>` in a method | hand out a borrow of the *input*, not of `self` | |
| `&'static str` | lives for the whole program (string literals) | `const NAME: &str = "koan";` |
| `s.match_indices(p)` | an iterator of `(byte_index, matched_slice)` | `"a-b-c".match_indices('-')` |
| `s.split_at(i)` | `(&s[..i], &s[i..])` | |
| `s.trim_start()`, `s.find(char::is_whitespace)` | | |

## Your task
This koan **starts with compile errors on purpose** (E0106, missing lifetime specifier). Add lifetimes until it compiles, then implement the bodies:

- `longest`: the longer of two strings (the first on a tie)
- `before`: the part of `text` before the first `sep` (all of `text` if there's no `sep`)
- `find_all`: every occurrence of `word` in `text`, as `Highlight`s that borrow from `text`
- `Words::next_word`: the next whitespace-separated word of the input, or `None` at the end
- `level_name`: `"debug"`, `"info"`, `"warn"`, or `"error"` for 3 and up

Careful: rustc's suggested fix gives *every* input the same `'a`. That's right for `longest`, but `before`, `find_all` and `next_word` promise more: their results come from one input only, and the checks drop the other one early to hold you to it.

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
