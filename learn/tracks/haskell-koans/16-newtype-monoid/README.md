# Koan 16 · newtype, Semigroup & Monoid

> The tournament keeps two scoreboards: one adds points, one keeps the best. Same numbers, different ways to combine them.

**Why it matters:** `newtype` gives an existing type a new identity at zero runtime cost. `Semigroup`/`Monoid` capture "things that combine", which is why `<>` works for strings, lists and maps.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `newtype N = N Int` | a new type wrapping exactly one value; free at runtime | `newtype Meters = Meters Double` |
| `<>` | Semigroup "combine" | `"ab" <> "cd"` → `"abcd"` |
| `X a <> X b = …` | define an operator method with a pattern on each side | see below |
| `mempty` | Monoid "empty": combining with it changes nothing | `(mempty :: String)` → `""` |
| `mconcat xs` | combine a whole list with `<>`, starting from `mempty` | `mconcat ["a", "b", "c"]` → `"abc"` |
| `foldr1 f xs` | `foldr` without a start value; the list must be non-empty | `foldr1 max [3, 7, 2]` → `7` |
| `dropWhile p`, `dropWhileEnd p` | drop leading / trailing elements while `p` holds | `dropWhile (== '0') "007"` → `"7"` |
| `isSpace`, `null` | is it whitespace? / is the list empty? | `null ""` → `True` |
| smart constructor | a function returning `Maybe T` that only builds valid values | see below |

```haskell
newtype Longest = Longest String deriving (Show)

instance Semigroup Longest where
  Longest a <> Longest b = if length b > length a then Longest b else Longest a

newtype Percent = Percent Int deriving (Show)

mkPercent :: Int -> Maybe Percent
mkPercent n
  | n < 0 || n > 100 = Nothing
  | otherwise        = Just (Percent n)
```

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
