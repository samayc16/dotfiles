# Koan 01 · Expressions & types

> You arrive at the Lambda Monastery. The gatekeeper asks you to compute a few things before you may enter.

**Why it matters:** Everything in Haskell is an expression with a type. Getting comfortable reading types (`Int`, `Double`, `String`, `Bool`) is the foundation for every later koan.

## Your task

Edit `Expressions.hs` and replace every `undefined`.

- `secondsPerDay`: hours × minutes × seconds.
- `average`: the average of 3.0, 4.0 and 8.0 (Doubles divide with `/`).
- `greeting`: `"Hello, "` and `"apprentice"` glued together with `++`.
- `tenIsEven`: use the Prelude function `even`.
- `remainder`: 17 modulo 5. Any function can be used infix with backticks: ``a `mod` b``.
- `halfOfSeven`: the `Int` 7 divided by 2 as a `Double`. You'll need `fromIntegral`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

expressions, Int/Double/String/Bool, infix functions, fromIntegral
