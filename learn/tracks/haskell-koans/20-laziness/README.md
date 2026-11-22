# Koan 20 · Laziness & infinite lists

> The monastery's library is infinite. You can still read the first few pages, as long as you never ask for the last one.

**Why it matters:** Haskell only computes what's needed. Infinite lists become ordinary values, and you separate *generating* data from *consuming* it.

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
