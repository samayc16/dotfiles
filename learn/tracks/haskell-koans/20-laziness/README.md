# Koan 20 · Laziness & infinite lists

> The monastery's library is infinite. You can still read the first few pages, as long as you never ask for the last one.

**Why it matters:** Haskell only computes what's needed. Infinite lists become ordinary values, and you separate *generating* data from *consuming* it.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `Integer` | whole numbers with no size limit (`Int` is 64-bit) | `(2 ^ 100 :: Integer)` |
| infinite lists | fine to define; only the part you consume is ever computed | `evens = [0, 2 ..]` |
| `takeWhile p xs` | take elements while `p` holds, stop at the first failure | `takeWhile (< 4) [1 ..]` → `[1,2,3]` |
| `iterate f x` | `[x, f x, f (f x), …]` forever | `take 4 (iterate (* 3) 1)` → `[1,3,9,27]` |
| `tail xs` | everything after the first element | `tail "abc"` → `"bc"` |
| `cycle xs` | repeat a list forever | `take 5 (cycle [1, 2])` → `[1,2,1,2,1]` |
| self-reference | a list may be defined from itself if each element only needs earlier ones | `powers = 1 : map (* 2) powers` |

## Your task

Edit `Lazy.hs` and replace every `undefined`.

- `naturals`: 0, 1, 2, … forever.
- `firstSquaresOver 10 == [16,25,36,49,64]`: the first 5 squares above n.
- `fibs`: all Fibonacci numbers (`0 : 1 : zipWith (+) fibs (tail fibs)`, a list defined in terms of itself!).
- `primes`: all primes (a simple sieve is fine).
- `collatz 6 == [6,3,10,5,16,8,4,2,1]` using `iterate` and `takeWhile`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

lazy evaluation, infinite lists, take/takeWhile, iterate, zipWith self-reference
