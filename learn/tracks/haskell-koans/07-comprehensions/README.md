# Koan 07 · List comprehensions & ranges

> The monastery's mathematician writes sets the way mathematicians do, and Haskell reads them directly.

**Why it matters:** Comprehensions (`[f x | x <- xs, p x]`) are Python's list comprehensions with superpowers: several generators, guards and pattern matches in one line.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `[e \| x <- xs]` | list comprehension: `e` for each `x` drawn from `xs` (Python `[e for x in xs]`) | `[x * x \| x <- [1, 2, 3]]` → `[1,4,9]` |
| `[e \| x <- xs, cond]` | a guard: keep only when `cond` is `True` | `[c \| c <- "hello", c /= 'l']` → `"heo"` |
| `x <- a, y <- b` | several generators = nested loops; the rightmost varies fastest | `[(x, y) \| x <- "ab", y <- [1, 2]]` → `[('a',1),('a',2),('b',1),('b',2)]` |
| `y <- [x .. 3]` | a later generator may use earlier variables | `[(x, y) \| x <- [1 .. 3], y <- [x .. 3]]` gives pairs with x ≤ y |
| `[a .. b]` | ranges work on any enumerable type, bounds can be expressions | `['a' .. 'e']` → `"abcde"`, `[0 .. n - 1]` |
| `[[Int]]` | a list of lists: a comprehension inside a comprehension | `[[r + c \| c <- [0, 1]] \| r <- [10, 20]]` → `[[10,11],[20,21]]` |
| `(a, b, c)` | a triple; tuples can be any fixed size | `(1, 'x', True)` |

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
