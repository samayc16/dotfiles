# Koan 05 · Recursion on lists

> There are no loops in the monastery. Every walk down a list is a function that handles one step and calls itself for the rest.

**Why it matters:** Recursion over `[]` and `(x:xs)` is how every list function in the Prelude is built. Once you can write these, `map`, `filter` and folds stop being magic.

## Your task

Edit `Recursion.hs` and replace every `undefined`.

Write these **without** the library versions (no `length`, `sum`, `reverse`, `elem`, `zip`):

- `myLength`, `mySum`, `myReverse`, `myElem`
- `countdown 3 == [3,2,1]`
- `myZip [1,2,3] "ab" == [(1,'a'),(2,'b')]` (stops at the shorter list)

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

recursion, base case, cons (:), lists
