# Koan 09 · where & let

> The healer's formulas are long. Name the intermediate values and they read like prose.

**Why it matters:** `where` and `let` give names to sub-expressions. That keeps formulas readable and avoids computing the same thing twice.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `let x = e in body` | local names inside one expression | `let r = 3 in r * r` → `9` |
| several bindings | line them up under each other in `let` or `where` | see below |
| `where` + guards | names defined in `where` are visible in every guard above it | see below |
| `pi` | π as a `Double` | `pi * 2` → `6.283…` |
| `-x` | negate a name; write `(-x)` when passing it as an argument | `abs (-x)` |
| `Maybe (Double, Double)` | a `Maybe` holding a pair: `Just (a, b)` or `Nothing` | `Just (1.0, 2.0)` |

```haskell
speedLabel :: Double -> Double -> String
speedLabel km hours
  | kmh > 100 = "fast"
  | otherwise = "slow"
  where
    kmh = km / hours

boxVolume :: Double -> Double -> Double -> Double
boxVolume w h d =
  let base = w * d
      vol = base * h
   in vol
```

## Your task

Edit `LocalDefs.hs` and replace every `undefined`.

- `bmiCategory weightKg heightM`: bmi = w / h²; below 18.5 is `"under"`, below 25 is `"normal"`, otherwise `"over"`. Use a `where` clause for `bmi`.
- `roots a b c`: real roots of ax² + bx + c as `Just (larger, smaller)`, or `Nothing` if the discriminant is negative. Use `let`.
- `cylinderArea r h`: 2πr² + 2πrh. Name the two parts.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

where clauses, let expressions, local helpers
