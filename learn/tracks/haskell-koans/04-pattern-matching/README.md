# Koan 04 · Pattern matching & guards

> The archivist sorts scrolls by shape, not by asking questions. Match on the shape of the data and Haskell picks the right equation.

**Why it matters:** Pattern matching replaces chains of `if`/`elif` and makes impossible states obvious. GHC even warns when you forget a case.

## Your task

Edit `Patterns.hs` and replace every `undefined`.

- `describe`: `"negative"`, `"zero"`, `"small"` (1–9) or `"large"`, using **guards** (`| cond = ...`).
- `fizzbuzz`: the classic; `"Fizz"`, `"Buzz"`, `"FizzBuzz"` or the number as a String (`show`).
- `firstOr def xs`: the first element, or `def` for an empty list: match on `[]` and `(x:_)`.
- `isVowel`: use a `case` expression.
- `swapPair (1, "a") == ("a", 1)`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

pattern matching, guards, case expressions, tuples
