# Koan 18 · Applicative & Monad with Maybe

> The monastery's records are spread across ledgers that may have gaps. Chain the lookups so a single gap stops the search.

**Why it matters:** `Maybe`'s Monad instance turns nested `case` pyramids into straight-line `do` code that stops at the first `Nothing`. The same idea powers Either, IO, parsers and lists.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `(+)` | an operator in parentheses is an ordinary function | `(+) 2 3` → `5` |
| `f <$> a <*> b` | apply a 2-argument function to two boxed values; any `Nothing` → `Nothing` | `max <$> Just 3 <*> Just 9` → `Just 9` |
| `do` in `Maybe` | each `x <- m` unwraps a `Just`; a `Nothing` stops the block | see below |
| `m >>= f` | "bind": feed the value inside `m` to `f`, which returns another box | `Just 8 >>= halfEven` → `Just 4` |
| `do` in lists | `x <- xs` means "for each x", like a comprehension | see below |
| `pure x` | put a plain value in the box: `Just x`, `[x]`, `Right x` | `(pure 1 :: [Int])` → `[1]` |

```haskell
halfEven :: Int -> Maybe Int
halfEven n = if even n then Just (n `div` 2) else Nothing

quarter :: Int -> Maybe Int
quarter n = do
  h <- halfEven n     -- Nothing here → the whole block is Nothing
  halfEven h          -- same as: halfEven n >>= halfEven

outfits :: [(String, String)]
outfits = do
  top <- ["shirt", "tee"]
  bottom <- ["jeans", "shorts"]
  pure (top, bottom)  -- all 4 combinations
```

## Your task

Edit `Monads.hs` and replace every `undefined`.

- `addMaybes`: add two `Maybe Int`s with `(+) <$> a <*> b`.
- `emailForUser`: id → name → email, using `do`-notation or `>>=`.
- `rootOfRecip`: `safeRecip`, then `safeRoot`, chained.
- `pairsUpTo 2 == [(1,1),(1,2),(2,2)]`: a `do`-block in the **list** monad (x ≤ y).

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

Applicative <*>, Monad >>=, do-notation, list monad
