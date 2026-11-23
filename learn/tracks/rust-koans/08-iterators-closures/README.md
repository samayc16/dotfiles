# 08 · Iterators and closures

## Why it matters
Iterator chains are Rust's loops: they read like a pipeline, can't index out of bounds, and compile to the same machine code as the hand-written `for` loop (zero-cost abstractions, for real). Closures are lambdas whose captures the borrow checker understands, which is what makes returning them, storing them and sending them to threads safe.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `\|x\| x + 1` | a closure (lambda); types inferred | `let inc = \|n: i32\| n + 1;` |
| captures | a closure borrows what it uses from the enclosing scope; `move \|\| …` takes ownership instead | `let limit = 3; let small = \|x: &i32\| *x < limit;` |
| `Fn` / `FnMut` / `FnOnce` | callable many times (reads its captures) / many times (mutates them) / once (consumes them) | `fn apply<F: Fn(i32) -> i32>(f: F) -> i32 { f(1) }` |
| `-> impl Fn(i32) -> i32` | return "some closure" without naming its type | `fn adder(k: i32) -> impl Fn(i32) -> i32 { move \|x\| x + k }` |
| `.iter()` | an iterator of `&T` over a slice or Vec | |
| `.filter(\|x\| …)`, `.map(\|x\| …)` | keep / transform items; lazy until consumed | `.filter(\|&&n\| n > 0)` |
| `.collect()` | run the chain into a collection; the type comes from context or `::<Vec<_>>` | |
| `.sum()`, `.count()` | consume into a number | |
| `.zip(other)` | pairs `(a, b)`, stopping at the shorter side | |
| `.take(n)`, `.take_while(\|x\| …)`, `.skip(n)` | | |
| `impl Iterator for T { type Item = X; fn next(&mut self) -> Option<X> }` | write `next` and get every adapter for free | see below |
| `(a, b) = (b, a + b);` | destructuring assignment | |

```rust
struct Countdown(u32);

impl Iterator for Countdown {
    type Item = u32;
    fn next(&mut self) -> Option<u32> {
        if self.0 == 0 {
            return None;
        }
        self.0 -= 1;
        Some(self.0 + 1)
    }
}
// Countdown(3).collect::<Vec<_>>() == [3, 2, 1]
```

## Your task
- `even_squares`, `count_longer`, `dot`: one iterator chain each
- `counter(step)`: a closure that returns `step`, `2·step`, `3·step`, … on successive calls
- `twice(f)`: a closure that applies `f` two times
- `Fib`: implement `Iterator` (0, 1, 1, 2, 3, 5, …), then `even_fib_sum`: the sum of the even Fibonacci numbers below `limit`

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
