# 14 · Fearless concurrency: threads, channels, Arc<Mutex>

## Why it matters
In C and C++, a data race is undefined behaviour you find with a sanitizer, if you're lucky. In Rust it's a compile error: the `Send` and `Sync` traits track what may cross threads, `Mutex<T>` owns the data it protects (you can't touch it without the lock), and scoped threads let workers borrow from the stack safely. Same OS threads, none of the fear.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `thread::spawn(move \|\| …)` | start an OS thread; the closure must own everything it uses (`'static`) | `let h = thread::spawn(move \|\| crunch(data));` |
| `handle.join()` | wait for the thread: `Ok(its return value)`, or `Err` if it panicked | `let n = h.join().unwrap();` |
| `thread::scope(\|s\| { s.spawn(…); })` | scoped threads may borrow from the caller's stack; all are joined when the scope ends | |
| `xs.chunks(n)` | non-overlapping sub-slices of length `n` (the last may be shorter) | |
| `a.div_ceil(b)` | division rounding up | `7usize.div_ceil(2)` → `4` |
| `mpsc::channel()` | `(Sender<T>, Receiver<T>)`: many producers, one consumer | |
| `tx.clone()`, `tx.send(v)` | another producer; send a value (moving it) | |
| `for v in rx` | receive until **every** `Sender` has been dropped | |
| `Arc<T>` | `Rc` for threads: an atomic reference count | `let cfg = Arc::new(cfg); let c2 = Arc::clone(&cfg);` |
| `Mutex<T>` | the data lives *inside* the lock; `.lock().unwrap()` returns a guard that unlocks when dropped | `*total.lock().unwrap() += 1;` |
| `Send`, `Sync` | marker traits: safe to move to / share with another thread. Checked by the compiler, so a data race doesn't compile | |
| `JoinHandle<T>` | a thread's handle; `join()` hands back its `T` | |
| `(0..n).map(\|_\| …)` | do something n times | |

## Your task
- `parallel_sum`: split the slice across `workers` scoped threads (at least one) and add up their partial sums
- `map_threads`: run `f` on each item in its own thread and return the results in input order, collected over a channel
- `hammer`: `threads` threads each add 1 to the shared counter `per_thread` times; return once all have finished
- `spawn_length_worker`: start a thread that receives lines and sends back their length in characters until the line channel closes, then returns how many lines it handled

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
