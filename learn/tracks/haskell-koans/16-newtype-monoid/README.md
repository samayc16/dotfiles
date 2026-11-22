# Koan 16 · newtype, Semigroup & Monoid

> The tournament keeps two scoreboards: one adds points, one keeps the best. Same numbers, different ways to combine them.

**Why it matters:** `newtype` gives an existing type a new identity at zero runtime cost. `Semigroup`/`Monoid` capture "things that combine", which is why `<>` works for strings, lists and maps.

## Your task

Edit `Monoids.hs` and replace every `undefined`.

- `Score`: `<>` adds, `mempty` is 0, so `totalScore` is just `mconcat`.
- `MaxScore`: `<>` keeps the larger. `best` is `Nothing` for an empty list.
- `mkName`: trim spaces; `Nothing` if what's left is empty. A **smart constructor** guarantees every `Name` is valid.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

newtype, Semigroup (<>), Monoid (mempty, mconcat), smart constructors
