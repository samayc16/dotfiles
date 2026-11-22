# Koan 12 · Algebraic data types

> The temple architect describes every room as a shape. Teach Haskell what a shape is.

**Why it matters:** `data` lets you model a domain precisely: a Shape is *exactly* a circle, a rectangle or a triangle. Pattern matching then handles each case, and GHC warns if you miss one.

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
