# Koan 12 · Algebraic data types

> The temple architect describes every room as a shape. Teach Haskell what a shape is.

**Why it matters:** `data` lets you model a domain precisely: a Shape is *exactly* a circle, a rectangle or a triangle. Pattern matching then handles each case, and GHC warns if you miss one.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `data Dir = North \| South` | a type with a fixed set of values (an enum) | `data Coin = Heads \| Tails` |
| `Circle Double` | a constructor carrying data; `Circle 2.0` builds a `Shape` | `data Money = Coins Int \| Note Int Int` |
| `deriving (Enum, Bounded)` | adds `succ`, ranges `[North ..]`, `minBound`, `maxBound` | `[North ..]` → `[North,South]` |
| one equation per constructor | pattern-match the constructor and name its fields | see below |
| `maximumBy (comparing f) xs` | the element with the largest `f` (Python `max(xs, key=f)`); needs two imports | `maximumBy (comparing length) ["ab", "abcd", "a"]` → `"abcd"` |

```haskell
import Data.List (maximumBy)   -- add imports right under the `module … where` line
import Data.Ord (comparing)

data Money = Coins Int | Note Int Int   -- Note value count

worth :: Money -> Int
worth (Coins n)  = n
worth (Note v c) = v * c
```

## Your task

Edit `Shapes.hs` and replace every `undefined`.

- `area` and `perimeter` for every `Shape` (triangle area: Heron's formula, s = half the perimeter, area = √(s(s−a)(s−b)(s−c))).
- `next`: Red → Green → Yellow → Red.
- `largest`: the shape with the biggest area, or `Nothing` for an empty list.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

data declarations, constructors with fields, deriving, Enum/Bounded
