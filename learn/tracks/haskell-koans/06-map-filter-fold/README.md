# Koan 06 · map, filter & folds

> The abbot hands you a sack of numbers and a sack of words. Process each one with a single line, no recursion this time.

**Why it matters:** `map`, `filter` and folds capture the recursion patterns from the last koan. Most real Haskell list code is a pipeline of these.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `filter p xs` | keep the elements where `p` is `True` | `filter (> 2) [1, 5, 2, 7]` → `[5,7]` |
| `x ^ n` | power with a whole-number exponent | `3 ^ 2` → `9`; the section `(^ 3)` cubes |
| `foldr f z xs` | combine from the right, starting at `z` | `foldr max 0 [3, 9, 4]` → `9` |
| `foldl f z xs` | combine from the left with an accumulator: `f (f z a) b` | see below |
| `\acc x -> …` | a lambda with two parameters | |
| `[1 .. 6]` | range: `[1,2,3,4,5,6]` | `[3 .. 5]` → `[3,4,5]` |
| `Maybe a`: `Just x` / `Nothing` | a value that might be missing (Python's `Optional` / `None`) | `Just 2.5 :: Maybe Double` |
| `sum xs` | add up a list | `sum [1.5, 2.5]` → `4.0` |

```haskell
-- foldl: walk left to right, carrying an accumulator
digitsToInt :: [Int] -> Int
digitsToInt ds = foldl (\acc d -> acc * 10 + d) 0 ds   -- [1,2,3] → 123
```

## Your task

Edit `Folds.hs` and replace every `undefined`.

- `squaresOfOdds [1..6] == [1,9,25]`
- `total` using `foldr`
- `countIf even [1..10] == 5`
- `longestWord`: the longest word; ties keep the **first** one; `""` for no words.
- `average`: `Nothing` for an empty list, otherwise `Just` the mean.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

map, filter, foldr, foldl, Maybe for empty input
