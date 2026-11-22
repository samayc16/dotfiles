# Koan 07 · List comprehensions & ranges

> The monastery's mathematician writes sets the way mathematicians do, and Haskell reads them directly.

**Why it matters:** Comprehensions (`[f x | x <- xs, p x]`) are Python's list comprehensions with superpowers: several generators, guards and pattern matches in one line.

## Your task

Edit `Comprehensions.hs` and replace every `undefined`.

- `evensUpTo 10 == [2,4,6,8,10]`
- `pythagorean n`: all `(a, b, c)` with `a <= b <= c <= n` and `a² + b² == c²`
- `grid 2 3 == [(0,0),(0,1),(0,2),(1,0),(1,1),(1,2)]`
- `lettersFrom 'w' == "wxyz"` (ranges work on Char!)
- `multiplicationTable 3 == [[1,2,3],[2,4,6],[3,6,9]]`

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

list comprehensions, ranges, multiple generators, guards in comprehensions
