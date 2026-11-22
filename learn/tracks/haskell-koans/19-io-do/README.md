# Koan 19 · IO & do-notation

> Launch day. The monastery's rocket needs a countdown, a roll call and a loud announcement.

**Why it matters:** In Haskell, side effects live in `IO` and the type says so. `do`-notation sequences actions just like a Python function body, but pure code can never secretly print or read files.

## Your task

Edit `Effects.hs` and replace every `undefined`.

- `countdown 3` prints `3`, `2`, `1`, then `liftoff!`, each on its own line.
- `greetAll ["ada","bo"]` prints `hello, ada` and `hello, bo` and **returns** how many it greeted.
- `sumActions`: run each `IO Int` and add up their results.
- `whenLoud flag msg`: print `msg` in uppercase only when `flag` is True (`when` from Control.Monad).

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

IO actions, do-notation, mapM_ / forM_, when, returning values from IO
