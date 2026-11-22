# Koan 15 · Polymorphism & constraints

> One function, every type. The monks write code once and reuse it for numbers, letters and coins.

**Why it matters:** A constraint like `Ord a =>` says "any type that can be compared". It's how generic code stays type-safe, like C++ concepts or Swift's `where T: Comparable`.

## Your task

Edit `Polymorphism.hs` and replace every `undefined`.

- `largest`: the maximum, or `Nothing` for an empty list.
- `countOf 'a' "banana" == 3`
- `joinShown [1,2,3] == "1, 2, 3"`
- `sumAndProduct [1,2,3,4] == (10, 24)`
- `clamp lo hi x`: keep `x` inside `[lo, hi]`.
- `dedupe [3,1,3,2,1] == [3,1,2]` (keep first occurrences). **It has no type signature yet.** Once it works, HLS shows the inferred one as a code lens; accept it with `<leader>cl`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

type variables, class constraints, Ord/Eq/Show/Num, type inference
