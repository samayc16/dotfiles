# Koan 06 · map, filter & folds

> The abbot hands you a sack of numbers and a sack of words. Process each one with a single line, no recursion this time.

**Why it matters:** `map`, `filter` and folds capture the recursion patterns from the last koan. Most real Haskell list code is a pipeline of these.

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
