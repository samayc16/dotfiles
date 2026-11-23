# Koan 05 · Recursion on lists

> There are no loops in the monastery. Every walk down a list is a function that handles one step and calls itself for the rest.

**Why it matters:** Recursion over `[]` and `(x:xs)` is how every list function in the Prelude is built. Once you can write these, `map`, `filter` and folds stop being magic.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `x : xs` | "cons": put `x` in front of list `xs` (`[1, 2]` is `1 : 2 : []`) | `'h' : "ey"` → `"hey"` |
| recursion | a function that calls itself on a smaller input, plus a base case that stops | see below |
| `[x]` | a one-element list | `[5] ++ [6]` → `[5,6]` |
| `if c then a else b` | an expression: both branches required, same type | `if 3 > 2 then "y" else "n"` → `"y"` |
| `Eq a =>` | **constraint**: "any type `a` that supports `==`". It goes before the type, joined by `=>` | `same :: Eq a => a -> a -> Bool` |
| `[(a, b)]` | a list of pairs | `[(1, 'x')] :: [(Int, Char)]` |
| patterns on 2 args | match every parameter; put the catch-all equation last | see below |

```haskell
myProduct :: [Int] -> Int
myProduct []         = 1                      -- base case: stop
myProduct (x : rest) = x * myProduct rest     -- one step, then recurse

upTo :: Int -> Int -> [Int]
upTo lo hi
  | lo > hi   = []
  | otherwise = lo : upTo (lo + 1) hi         -- upTo 2 4 → [2,3,4]

bothEmpty :: [a] -> [b] -> Bool
bothEmpty [] [] = True
bothEmpty _  _  = False
```

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
