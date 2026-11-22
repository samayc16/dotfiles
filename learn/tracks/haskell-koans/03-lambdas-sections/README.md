# Koan 03 · Lambdas, sections & composition

> The monks never name a function they use only once. They write it inline, or build it by snapping two functions together.

**Why it matters:** Lambdas (`\x -> ...`), sections (`(*2)`, `(++ "!")`) and composition (`f . g`) are how idiomatic Haskell avoids boilerplate. Python's `lambda` is the cousin.

## Your task

Edit `Lambdas.hs` and replace every `undefined`.

- `doubleAll`: `map` with the section `(*2)`.
- `incrementAll`: `map` with a lambda `\x -> ...`.
- `shout "om" == "OM!"`: compose `map toUpper` with appending `"!"`.
- `lengthsOfWords "the quick fox" == [3,5,3]`: `words`, then lengths.
- `applyAll [(+1), (*2)] 5 == 11`: compose a whole list of functions (rightmost runs first).

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

lambdas, operator sections, function composition (.), map
