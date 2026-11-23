# Koan 04 · Pattern matching & guards

> The archivist sorts scrolls by shape, not by asking questions. Match on the shape of the data and Haskell picks the right equation.

**Why it matters:** Pattern matching replaces chains of `if`/`elif` and makes impossible states obvious. GHC even warns when you forget a case.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `==` `/=` `<` `<=` `>` `>=` | comparisons, giving a `Bool` (`/=` is "not equal") | `3 /= 4` → `True` |
| `&&`, `\|\|`, `not` | and, or, not | `not (1 > 2)` → `True` |
| `\| cond = result` | **guard**: the first `True` condition picks the result; `otherwise` is just `True` | see `grade` below |
| `show x` | turn a value into a `String` | `show 42` → `"42"` |
| several equations | one equation per input shape; the first that matches wins | see `isEmpty` below |
| `[]`, `(x : rest)` | list patterns: empty list / first element `x` plus the rest | |
| `_` | wildcard pattern: matches anything, ignores it | `always5 _ = 5` |
| `case e of p -> r` | pattern match inside an expression | see `yes` below |
| `(a, b)`, `'c'` | a tuple (fixed size, mixed types) / a single `Char` | `(3, "three") :: (Int, String)` |

```haskell
grade :: Int -> String
grade score
  | score >= 90 = "A"        -- checked top to bottom
  | otherwise   = "C"

isEmpty :: [a] -> Bool
isEmpty []      = True
isEmpty (_ : _) = False

yes :: Char -> Bool
yes c = case c of
  'y' -> True
  _   -> False

addPair :: (Int, Int) -> Int
addPair (a, b) = a + b
```

You may replace a starter line like `f x = undefined` with several equations or guards. Keep the `::` line.

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
