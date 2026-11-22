# Koan 18 · Applicative & Monad with Maybe

> The monastery's records are spread across ledgers that may have gaps. Chain the lookups so a single gap stops the search.

**Why it matters:** `Maybe`'s Monad instance turns nested `case` pyramids into straight-line `do` code that stops at the first `Nothing`. The same idea powers Either, IO, parsers and lists.

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
