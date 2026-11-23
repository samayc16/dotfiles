# Koan 21 · Data.Map: dictionaries

> The scribes want to know which words appear most in the sacred texts, and the kitchen wants an inventory.

**Why it matters:** `Data.Map` is Haskell's persistent dictionary: every insert returns a new map and the old one stays valid. It ships with GHC (`containers`).

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `import qualified Data.Map.Strict as Map` | use that module's names with a prefix (`Map.insert`) so they don't clash with the Prelude | |
| `import Data.Ord (Down (..))` | `(..)` also imports the type's constructors | |
| `Map k v` | a dictionary from keys `k` to values `v` | `Map String Int` |
| `Map.fromList`, `Map.toList` | pairs → map, map → pairs (sorted by key) | `Map.toList (Map.fromList [(2, 'b'), (1, 'a')])` → `[(1,'a'),(2,'b')]` |
| `Map.fromListWith f` | like `fromList`, but values of duplicate keys are combined with `f` | `Map.fromListWith (++) [(1, "a"), (1, "b")]` → `fromList [(1,"ba")]` |
| `Map.insertWith f k v m` | insert, or combine with the existing value using `f` | `Map.insertWith (+) "x" 5 m` |
| `Map.findWithDefault d k m` | look up `k`, or `d` if it's missing | `Map.findWithDefault 0 "y" m` |
| `sortBy (comparing key)` | sort by a computed key; tuple keys sort by first part, then second | `sortBy (comparing (\s -> (length s, s))) ["bb", "a", "ab"]` → `["a","ab","bb"]` |
| `Down x` | flips the ordering of `x`: sort descending | `sortBy (comparing Down) [1, 3, 2]` → `[3,2,1]` |
| `\(a, b) -> …` | a lambda can pattern-match a tuple | `map (\(k, v) -> v) pairs` |
| `isAlpha`, `toLower` | is it a letter? / lowercase one `Char` | `toLower 'Q'` → `'q'` |

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
