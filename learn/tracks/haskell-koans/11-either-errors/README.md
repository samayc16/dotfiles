# Koan 11 · Either: errors as values

> The gate needs an age before letting visitors in. Visitors type all kinds of nonsense.

**Why it matters:** `Either err a` is `Maybe` that also explains *why* it failed. Errors are plain values in the type, not exceptions you might forget to catch.

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
