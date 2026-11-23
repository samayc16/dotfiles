# 16 · unsafe and FFI: raw pointers and calling C

## Why it matters
Safe Rust rests on a small amount of `unsafe` code underneath: `Vec`, `split_at_mut`, every call into C. `unsafe` doesn't switch the borrow checker off; it unlocks a few extra powers (dereferencing raw pointers, calling unsafe functions) and makes *you* responsible for their rules. The idiom is small `unsafe` blocks, each with a `// SAFETY:` comment, wrapped in safe functions whose types make misuse impossible. It's also how you call the C libraries you already know.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `*const T`, `*mut T` | raw pointers: may be null, dangling or aliased. Making one is safe; dereferencing one is `unsafe` | `let p: *const u8 = bytes.as_ptr();` |
| `unsafe { … }` | "I've checked what the compiler can't": allows raw derefs and unsafe calls | |
| `unsafe fn` + `# Safety` doc | preconditions the *caller* must uphold; in the 2024 edition its body still needs `unsafe { }` blocks | |
| `// SAFETY:` | the convention: say why each `unsafe` block is sound | |
| `p.add(i)`, `*p` | pointer arithmetic in elements (C's `p + i`), dereference | |
| `p.cast::<U>()` | reinterpret the pointee type | `void_ptr.cast::<f64>()` |
| `unsafe extern "C" { fn f(…); }` | declare C functions (2024 edition: the block itself is `unsafe`) | `fn puts(s: *const c_char) -> c_int;` |
| `safe fn` in that block | a C function you vouch is safe for any arguments, callable without `unsafe` | `safe fn labs(x: c_long) -> c_long;` |
| `unsafe extern "C" fn` | a Rust function with the C calling convention, passable to C as a callback | |
| `CString::new(s)`, `.as_ptr()` | an owned NUL-terminated copy for C; `Err` if `s` contains `\0` | |
| `slice::from_raw_parts_mut(p, n)` | a `&mut [T]` from a pointer and a length (unsafe) | |
| `c_char`, `c_int`, `c_void` | C's types, from `std::ffi` | |
| `size_of::<T>()` | `sizeof(T)` | |
| `a.cmp(&b) as c_int` | an `Ordering` as `-1`, `0` or `1` | |

## Your task
- `c_strlen`: C's `strlen` on a Rust string (`None` if it contains a NUL byte)
- `distance`: `|a - b|` using C's `abs`, declared `safe`
- `compare_i32` + `c_sort`: sort a slice with C's `qsort` and a Rust callback
- `sum_raw`: add up `len` numbers starting at a raw pointer (an `unsafe fn`); `sum` is its safe wrapper
- `split_mut`: two non-overlapping `&mut` halves of one slice, like `std`'s `split_at_mut`

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
