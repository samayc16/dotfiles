# Koan 11 · Either: errors as values

> The gate needs an age before letting visitors in. Visitors type all kinds of nonsense.

**Why it matters:** `Either err a` is `Maybe` that also explains *why* it failed. Errors are plain values in the type, not exceptions you might forget to catch.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `data E = A String \| B Int` | a new type with alternatives ("constructors"), each carrying data | `data Temp = Freezing \| Fine Int` |
| `deriving (Show, Eq)` | auto-generate printing and `==` for the type | |
| `Either e a`: `Left err` / `Right x` | a result that is an error (`Left`) or a success (`Right`) | `Right 3 :: Either String Int` |
| `readMaybe s` | parse a `String`; `Nothing` if it isn't valid. Target type comes from context | `readMaybe "12" :: Maybe Int` → `Just 12` |
| `e :: T` | annotate one expression's type inline | `(readMaybe "x" :: Maybe Int)` → `Nothing` |
| `Just n \| cond -> …` | a `case` branch can have guards too | see below |
| `do` + `x <- step` | run steps in order; a `Left` stops the whole block | see below |
| `pure x` | wrap a plain value as a success (`Right x` here) | |
| `mapM f xs` | run `f` on every element, collect the successes; the first `Left` wins (`traverse` is the same) | see below |

```haskell
parseNum :: String -> Either String Int
parseNum s = case readMaybe s of
  Nothing -> Left ("not a number: " ++ s)
  Just n
    | n > 99    -> Left "too big"
    | otherwise -> Right n

doubled :: String -> Either String Int
doubled s = do
  n <- parseNum s        -- a Left here is returned immediately
  pure (n * 2)           -- doubled "21" → Right 42

-- mapM parseNum ["1", "x", "y"] → Left "not a number: x"
```

## Your task

Edit `Errors.hs` and replace every `undefined`.

- `parseAge`: `Left (NotANumber s)` if it isn't a number, `Left (Negative n)` below 0, `Left (TooOld n)` above 150, else `Right n`. (`readMaybe` from Text.Read.)
- `canEnter`: `Right "welcome"` for 18+, `Right "too young"` otherwise; parse errors pass through.
- `parseAll`: parse every string; the **first** error wins. (`mapM` or `traverse` do exactly this.)

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

Either, custom error types, readMaybe, mapM / traverse
