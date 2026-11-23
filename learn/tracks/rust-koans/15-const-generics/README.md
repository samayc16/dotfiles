# 15 · Const generics: sizes in the type

## Why it matters
Array sizes, matrix shapes and buffer capacities can live in the type, like C++ non-type template parameters. Mismatched shapes become compile errors, fixed-capacity containers need no heap, and the size is known to the optimiser. `std` uses this everywhere: `[T; N]` implements traits for every `N`, and `try_into()` turns a slice into an array of exactly the length the caller asked for.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `struct S<T, const N: usize>` | a type parameterised by a *value* known at compile time (≈ `template <typename T, size_t N>`) | `struct Ring<T, const CAP: usize> { buf: [T; CAP] }` |
| `impl<T, const N: usize> S<T, N>` | methods for every `N`; inside, `N` is a plain `usize` | |
| `[v; N]` | an array of `N` copies of `v` (`v` must be `Copy` or a constant) | `[0u8; 16]` |
| `fn f<const N: usize>(…)` | a const-generic function | |
| `f::<3>(…)` | choose `N` explicitly (turbofish) | `zeros::<8>()` |
| inferred `N` | from the expected type | `let a: [u8; 4] = f(bytes);` |
| `const { assert!(…) }` | evaluated at compile time, once per `N` | |
| `[[i32; C]; R]` | R rows of C columns | |
| `opt.take()` | moves the value out of an `Option`, leaving `None` | |
| `xs.as_chunks::<N>()` | `(&[[T; N]], &[T])`: the full chunks as arrays (sizes known at compile time), plus the leftover | `let (pixels, _) = rgb.as_chunks::<3>();` |
| `slice.try_into()` | `&[T]` → `[T; N]`, `Err` if the length is wrong | `let a: [u8; 2] = s[..2].try_into().unwrap();` |
| `bytes.get(..n)` | `Some(&bytes[..n])`, or `None` if it's too short (no panic) | |
| `b"text"` | a byte-string literal: `&[u8; N]` | |
| `Result<(), T>` | success with no value, or the rejected value handed back | |

## Your task
- `Stack<T, N>`: a stack that never allocates. `new`, `push` (hands the value back as `Err` when full), `pop`, `len`, `is_empty`, `capacity`
- `chunk_sums::<N>`: the sum of each complete group of N numbers
- `transpose`: an R×C array of arrays becomes C×R
- `first_n`: the first N bytes as a `[u8; N]`, or `None` if there aren't enough (N comes from the caller's type)

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
