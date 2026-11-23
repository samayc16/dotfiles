# 07 · Trait objects: dyn Trait and dynamic dispatch

## Why it matters
Generics are resolved at compile time; sometimes the concrete type is only known at runtime (a plugin chosen from a config file, a list of different shapes). `dyn Trait` is Rust's virtual dispatch: a fat pointer to the data plus a vtable, with no inheritance hierarchy needed, and `Box<dyn Trait>` owns one, much like `std::unique_ptr<Base>`.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `dyn Trait` | "some type implementing Trait", decided at runtime; calls go through a vtable, like C++ `virtual` | `&dyn Display` |
| `Box<dyn Trait>` | an owned trait object on the heap (≈ `std::unique_ptr<Base>`) | `let s: Box<dyn Shape> = Box::new(Circle(1.0));` |
| `Vec<Box<dyn Trait>>` | a list of *different* concrete types behind one interface | `let zoo: Vec<Box<dyn Animal>> = vec![Box::new(Cat), Box::new(Cow)];` |
| `&dyn Trait` | a borrowed trait object (a fat pointer: data + vtable) | `fn log(item: &dyn Display)` |
| generic `T` vs `dyn` | `T: Trait`: one copy per type, static dispatch, one type per call. `dyn Trait`: one copy, dynamic dispatch, mixed types | |
| `fn f(mut self, …) -> Self` | builder style: consume, modify, hand back | `fn topping(mut self, t: Topping) -> Self { self.toppings.push(t); self }` |
| `for x in &self.items` | iterate a field by reference | |
| `s.to_uppercase()`, `s.repeat(n)`, `s.replace(a, b)` | | `"ab".repeat(2)` → `"abab"` |
| `split_whitespace().collect()` | words into a `Vec<&str>` | |
| `match v.as_slice() { ["go", dir] => … }` | slice patterns: match the length and the contents at once (more in koan 13) | `["move", x, y] => …` |
| `text.parse().ok()?` | parse, turn failure into `None`, return early | |
| `#[derive(Default)]` | `Type::default()` with every field defaulted (an empty Vec here) | |

## Your task
- `apply` for `Upper` (uppercase), `Repeat(n)` (the input n times) and `Replace { from, to }` (every `from` becomes `to`)
- `Pipeline::then` adds a step and returns the pipeline, so calls chain; `step_count`; `run` feeds each step's output to the next
- `parse_step`: `"upper"`, `"repeat 3"`, `"replace a b"` → the matching boxed step; anything else → `None`
- `total_len`: the summed output length of each borrowed step applied to `input` on its own

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
