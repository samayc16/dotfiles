# Koan 19 · IO & do-notation

> Launch day. The monastery's rocket needs a countdown, a roll call and a loud announcement.

**Why it matters:** In Haskell, side effects live in `IO` and the type says so. `do`-notation sequences actions just like a Python function body, but pure code can never secretly print or read files.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `IO a` | an action that may do I/O when run, and produces an `a` | `getLine :: IO String` |
| `()`, `IO ()` | "unit", the boring value / an action run only for its effect | `putStrLn :: String -> IO ()` |
| `putStrLn s`, `print x` | print a `String` / print any showable value | `print 3` prints `3` |
| `do` in IO | run actions in order; the last line is the result | see below |
| `x <- action` | run an action and name its result (only inside `do`) | |
| `let x = e` in `do` | a local name inside a `do` block (no `in`) | |
| `pure x` | an action that does nothing and returns `x` | |
| `forM_ xs f` | run `f` for every element, ignore the results (a for loop) | `forM_ [1, 2] print` |
| `when b action` | run `action` only if `b` is `True` | `when (n > 3) (putStrLn "big")` |
| `sequence actions` | run a list of actions, collect their results in a list | `sequence [pure 1, pure 2]` gives `[1,2]` |
| `f $ x` | apply with the lowest precedence; saves parentheses around the last argument | `print $ 2 + 3` = `print (2 + 3)` |
| `[a, b .. c]` | stepped range | `[10, 8 .. 2]` → `[10,8,6,4,2]` |

```haskell
report :: [Int] -> IO Int
report xs = do
  forM_ (filter odd xs) $ \x -> putStrLn ("odd: " ++ show x)
  let total = sum xs
  when (total > 10) (putStrLn "big total")
  pure total               -- the result of the whole action

main :: IO ()
main = do
  t <- report [3, 4, 5]    -- run it and name its result
  print t
```

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
