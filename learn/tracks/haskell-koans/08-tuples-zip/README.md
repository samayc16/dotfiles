# Koan 08 · Tuples & zip

> The census monk keeps two scrolls: names and ages. Your job is to stitch them together.

**Why it matters:** Tuples group a fixed number of values of different types. `zip` and friends are the bread and butter of pairing data up.

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
