# 11 · Box, Rc and RefCell: heap, sharing, interior mutability

## Why it matters
Ownership is a tree; real data structures sometimes aren't. `Box` gives you heap allocation and recursive types, `Rc` gives shared ownership (a node with two parents), and `RefCell` moves the borrow check to runtime for the cases the compiler can't prove. Together they cover what C++ does with `unique_ptr`, `shared_ptr` and `mutable`, with leaks and data races still off the table. `Drop` is RAII: cleanup that can't be forgotten.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `Box<T>` | an owning pointer to a heap value (≈ `std::unique_ptr`), freed when the Box is dropped | `let big = Box::new([0u8; 4096]);` |
| recursive `enum` | needs a `Box` for the recursive part, or its size would be infinite (E0072) | `enum Expr { Num(i64), Neg(Box<Expr>) }` |
| `Rc<T>` | shared ownership, reference counted, single-threaded (≈ `std::shared_ptr`) | `let a = Rc::new(cfg); let b = Rc::clone(&a);` |
| `Rc::clone(&rc)` | one more owner: bumps the count, copies nothing | |
| `Rc::strong_count(&rc)` | how many owners there are right now | |
| `RefCell<T>` | lets you mutate through a shared reference; the borrow rules are checked at **runtime** | |
| `.borrow()`, `.borrow_mut()` | `Ref<T>` / `RefMut<T>` guards; a second mutable borrow panics | `cell.borrow_mut().push(x);` |
| `.try_borrow_mut()` | `Err(BorrowMutError)` instead of a panic | |
| `type Shared<T> = Rc<RefCell<T>>;` | a type alias: shared *and* mutable, the classic combination | |
| `impl Drop for T { fn drop(&mut self) { … } }` | a destructor; locals drop in reverse order of declaration | see below |
| `drop(x)` | drop `x` now (it's just a function that takes ownership) | |
| `*cell.borrow()` | the value inside a guard | |
| `for &x in xs.iter().rev()` | walk backwards, copying each item | |

```rust
struct Noisy(&'static str);

impl Drop for Noisy {
    fn drop(&mut self) {
        println!("bye {}", self.0);
    }
}
// { let _a = Noisy("a"); let _b = Noisy("b"); }   prints "bye b", then "bye a"
```

## Your task
- `List::from_slice` builds a cons list in the same order; `List::sum` adds it up recursively
- `Listener::join` shares (not copies) a playlist; `add` appends a song every listener sees; `count`
- `owners`: how many `Rc` owners a value has
- `Guard::open` logs `"open <name>"`; dropping a guard logs `"close <name>"`
- `try_double`: double the value in a `RefCell`, or return the `BorrowMutError` if it's already borrowed

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
