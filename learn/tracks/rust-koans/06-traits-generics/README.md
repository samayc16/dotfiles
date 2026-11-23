# 06 · Traits and generics: shared behaviour, zero cost

## Why it matters
Traits are how Rust shares behaviour: no inheritance, just 'this type can do X'. Generic functions with trait bounds compile to specialised code per type, like C++ templates, but the bounds are checked when the generic is *defined*, so errors point at the real problem instead of 40 lines of instantiation backtrace. Operator overloading and `{}` printing are just traits too.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `trait T { fn m(&self) -> X; }` | a set of methods types can implement (an interface, or a C++ concept with teeth) | `trait Area { fn area(&self) -> f64; }` |
| default method | a trait method with a body; implementors may override it | `fn summary(&self) -> String { format!("[{}]", self.title()) }` |
| `impl T for Type { … }` | implement a trait for a type | `impl Area for Square { … }` |
| `fn f<T: Bound>(x: T)` | generic with a trait bound; compiled once per concrete type (monomorphised, like a template) | `fn show<T: Display>(x: T)` |
| `T: A + B` | several bounds | `T: Display + Clone` |
| `PartialOrd`, `Copy` | the traits behind `<` `>` and implicit copies | |
| `impl Add for T { type Output = T; fn add(self, o: T) -> T { … } }` | operator overloading for `+` (`std::ops`) | see below |
| `Add<Output = T>` | a bound on an associated type: "adding gives back a `T`" | `T: Mul<Output = T>` |
| `struct Dog;` | a unit struct: no fields, its only value is `Dog` | |
| `{:02}` | pad with zeros to width 2 | `format!("{:02}", 7)` → `"07"` |
| `f::<u8>(…)` | turbofish: name a generic's type explicitly | `"5".parse::<i32>()` |

```rust
#[derive(Debug, Clone, Copy, PartialEq)]
struct Vec2 { x: f64, y: f64 }

impl Add for Vec2 {
    type Output = Vec2;
    fn add(self, o: Vec2) -> Vec2 {
        Vec2 { x: self.x + o.x, y: self.y + o.y }
    }
}
// Vec2 { x: 1.0, y: 2.0 } + Vec2 { x: 0.5, y: 0.5 } == Vec2 { x: 1.5, y: 2.5 }
```

## Your task
- implement `Describe` for `Dog` (name `"a dog"`, default `describe`) and `Robot` (name `"robot #7"`, and `describe` overridden to `"BEEP. I AM ROBOT #7."`)
- `introduce_all`: the `describe()` of every item, for any `T: Describe`
- `largest`: the largest element of any slice whose elements can be compared and copied; add the bounds the compiler asks for
- `Money`: make `+` add cents and `{}` print `"$12.05"`
- `sum_all`: add up any slice of values that support `+`, starting from `zero`

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
