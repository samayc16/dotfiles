# Koan 03 · Lambdas, sections & composition

> The monks never name a function they use only once. They write it inline, or build it by snapping two functions together.

**Why it matters:** Lambdas (`\x -> ...`), sections (`(*2)`, `(++ "!")`) and composition (`f . g`) are how idiomatic Haskell avoids boilerplate. Python's `lambda` is the cousin.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `import M (f)` | bring `f` from module `M` into scope (goes under the `module` line) | `import Data.Char (isDigit)` |
| `[Int]`, `[1, 2, 3]` | list type / list literal; every element has the same type | `[True, False] :: [Bool]` |
| `\x -> body` | lambda: an unnamed function (Python `lambda x: body`) | `(\x -> x * 10) 4` → `40` |
| `(op y)`, `(y op)` | **section**: an operator with one side filled in | `(/ 2) 9` → `4.5`, `(2 /) 8` → `0.25` |
| `map f xs` | apply `f` to every element | `map negate [1, 2]` → `[-1,-2]` |
| `f . g` | composition: `(f . g) x = f (g x)`, the right one runs first | `(negate . abs) (-3)` → `-3` |
| `name = f` (no parameter) | "point-free": the definition *is* a function, the argument stays unnamed | `negateAll = map negate` means `negateAll xs = map negate xs` |
| `words`, `length`, `toUpper` | split on whitespace / count elements / uppercase one `Char` | `words "a b"` → `["a","b"]` |
| `foldr f z xs`, `id` | combine a list from the right: `foldr f z [a, b] = f a (f b z)`; `id x = x` | `foldr (+) 0 [1, 2, 3]` → `6` |

Gotcha: `(- 1)` is the number −1, not a section. Write `subtract 1` instead.

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
