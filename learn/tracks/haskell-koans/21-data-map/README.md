# Koan 21 · Data.Map: dictionaries

> The scribes want to know which words appear most in the sacred texts, and the kitchen wants an inventory.

**Why it matters:** `Data.Map` is Haskell's persistent dictionary: every insert returns a new map and the old one stays valid. It ships with GHC (`containers`).

## Your task

Edit `WordCount.hs` and replace every `undefined`.

- `wordFreq "The cat. the hat!"`: lowercase, letters only, so `the` counts 2.
- `topN n m`: the `n` most frequent `(word, count)`, by count descending, then word ascending.
- `inventory`: build a map, **summing** duplicate items (`Map.fromListWith`).
- `restock item n`: add `n` to the item's count, or insert it (`Map.insertWith`).
- `countOf item m`: 0 when missing (`Map.findWithDefault`).

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

Data.Map, qualified imports, insertWith / fromListWith, findWithDefault, sortBy
