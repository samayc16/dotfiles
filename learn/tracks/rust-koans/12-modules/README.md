# 12 · Modules and visibility: mod, pub, use and files

## Why it matters
Modules are Rust's unit of encapsulation: privacy is per module, not per class, and a crate's public API is exactly what's reachable through `pub` paths. The file-system rule trips up everyone coming from C and C++: a `.rs` file is not a translation unit, it's compiled only when a `mod` declaration pulls it into the tree.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `mod name { … }` | an inline module: a namespace that is also a privacy boundary | `mod audio { pub fn beep() {} }` |
| `mod name;` | "this module's code is in `name.rs` next to me". A file is NOT compiled until some module declares it | `mod net;` → `src/net.rs` |
| private by default | an item is visible in its own module and that module's children | |
| `pub` | visible wherever its parent module is visible | `pub fn play() {}` |
| `pub(crate)` | visible anywhere in this crate, never outside it | `pub(crate) const RATE: u32 = 3;` |
| field privacy | each field is private unless marked `pub`, even in a `pub struct` | `pub struct User { pub name: String, id: u64 }` |
| `use a::b::C;` | bring a name into scope | `use std::collections::HashMap;` |
| `pub use a::b::C;` | re-export: `C` is also reachable from here | `pub use net::Client;` |
| `super::x`, `crate::x`, `self::x` | the parent module, the crate root, this module | `super::helper()` |
| `koan::…` | in tests/checks.rs, the name of your crate (`[lib] name` in Cargo.toml) | |
| `x as u64` | an explicit numeric conversion (there are no implicit ones) | `n as f64` |

## Your task
This koan **starts with compile errors on purpose**: the checks in `tests/checks.rs` use your crate from the outside (`koan::…`), and right now they can't reach what they need.

- make `src/inventory.rs` part of the crate as the public module `koan::inventory`
- make public exactly what the checks use: the `pricing` module, `with_tax`, `discounts::bulk` and `discounts::checkout`, `Item::new` and `Item`'s `name` field. Keep `Item`'s `count` field private (there's a getter) and `TAX_PERCENT` crate-only
- re-export `Item` at the crate root, so `koan::Item` works
- implement the `todo!()`s; `checkout` must reuse `with_tax` from its parent module

Edit `src/lib.rs` and `src/inventory.rs` until every check passes.

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
