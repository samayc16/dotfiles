# Koan 10 · Maybe: values that might be missing

> The tea house menu is short. Customers order things that aren't on it, and you must never crash.

**Why it matters:** Haskell has no null. `Maybe a` makes "might be missing" part of the type, so the compiler makes you handle it. No more NoneType errors.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `Just x` / `Nothing` as patterns | take a `Maybe` apart in an equation or `case` | see below |
| literal pattern | an equation can match one specific value | `isZero 0 = True` then `isZero _ = False` |
| `fromMaybe d m` | the value inside, or the default `d` for `Nothing` | `fromMaybe 0 (Just 4)` → `4`, `fromMaybe 0 Nothing` → `0` |
| `maybe d f m` | `d` for `Nothing`, `f x` for `Just x` | `maybe "none" show (Just 3)` → `"3"` |
| `case (a, b) of` | match two things at once by pairing them up | see below |

```haskell
describeAge :: Maybe Int -> String
describeAge Nothing  = "unknown"
describeAge (Just n) = "age " ++ show n

bothTimes :: Maybe Int -> Maybe Int -> Maybe Int
bothTimes x y = case (x, y) of
  (Just a, Just b) -> Just (a * b)
  _                -> Nothing
```

## Your task

Edit `Maybes.hs` and replace every `undefined`.

- `safeDiv 10 2 == Just 5`, `safeDiv 1 0 == Nothing`
- `safeHead [] == Nothing`, `safeHead [7] == Just 7`
- `priceOf "tea" == Just 3.5` (look it up in `menu`)
- `priceOrZero "pizza" == 0` (`fromMaybe` from Data.Maybe, or `maybe`)
- `totalPrice ["tea","mochi"] == Just 7.5`, and `Nothing` if **any** item is unknown.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

Maybe, Just/Nothing, lookup, fromMaybe, maybe
