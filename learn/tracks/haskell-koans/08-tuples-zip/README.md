# Koan 08 · Tuples & zip

> The census monk keeps two scrolls: names and ages. Your job is to stitch them together.

**Why it matters:** Tuples group a fixed number of values of different types. `zip` and friends are the bread and butter of pairing data up.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `zip xs ys` | pair elements up; stops at the shorter list | `zip "xy" [True, False, True]` → `[('x',True),('y',False)]` |
| `zipWith f xs ys` | combine pairwise with `f` | `zipWith max [1, 9] [5, 2]` → `[5,9]` |
| `unzip` | list of pairs → pair of lists | `unzip [('x', True)]` → `("x",[True])` |
| `fst`, `snd` | first / second part of a pair | `snd (1, "one")` → `"one"` |
| `[1 ..]`, `take n` | an infinite range is fine if something stops reading it / the first `n` elements | `take 3 [10 ..]` → `[10,11,12]` |
| `[(String, Int)]` | "association list": key/value pairs | `[("pi", 3)]` |
| `lookup k pairs` | the value for key `k`, as a `Maybe` | `lookup 'b' [('a', 1), ('b', 2)]` → `Just 2` |
| `([a], [b])` | a tuple whose parts are lists | `("ab", [1, 2])` |

## Your task

Edit `Tuples.hs` and replace every `undefined`.

- `pairUp [1,2] "ab" == [(1,'a'),(2,'b')]`
- `dotProduct [1,2,3] [4,5,6] == 32` (use `zipWith`)
- `indexed "ab" == [(1,'a'),(2,'b')]` (numbering starts at 1; an infinite range is fine!)
- `ageOf "bo" [("ada",36),("bo",7)] == Just 7` (Prelude has `lookup`)
- `splitPairs [(1,'a'),(2,'b')] == ([1,2],"ab")`

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

tuples, zip, zipWith, lookup, unzip
