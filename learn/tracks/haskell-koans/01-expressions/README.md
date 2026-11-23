# Koan 01 · Expressions & types

> You arrive at the Lambda Monastery. The gatekeeper asks you to compute a few things before you may enter.

**Why it matters:** Everything in Haskell is an expression with a type. Getting comfortable reading types (`Int`, `Double`, `String`, `Bool`) is the foundation for every later koan.

## Haskell in 2 minutes

How to read a koan file:

```haskell
-- a comment, like # in Python.   {- a block comment -}   -- | a doc comment
module Gate where          -- file header: "this file is the module Gate"

answer :: Int              -- type signature: "answer has type Int"
answer = 6 * 7             -- definition: "answer IS 6 * 7". Names never change value.

shout :: String -> String  -- a function from String to String
shout s = s ++ "!"         -- name, parameter, =, body. No return, no braces, no colons.
```

| Python | Haskell | Note |
|---|---|---|
| `f(x, y)` | `f x y` | calling = writing the arguments after the name, separated by spaces |
| `f(g(x))` | `f (g x)` | parentheses only **group**; `f g x` would hand `g` itself to `f` |
| `f(-3)` | `f (-3)` | negative numbers need parentheses |
| `x: int` | `x :: Int` | `::` reads "has type" |
| `raise NotImplementedError` | `undefined` | compiles as any type, crashes when run: replace each one |
| `"hi"` / `'c'` | `"hi"` / `'c'` | double quotes = `String`, single quotes = one `Char` |

**Basic types:** `Int` (whole numbers), `Double` (decimals), `Bool` (`True` / `False`), `String` (text).

**No automatic number conversion.** Python quietly turns `7 / 2` into `3.5`. Haskell never mixes `Int` and `Double` for you:

- `/` only works on fractional types like `Double`. Whole numbers use `div` and `mod`.
- A bare literal (`7`, `2`) adapts to whatever type is needed. A *name* whose type is `Int` stays `Int`.
- `fromIntegral` is the explicit conversion: "turn this whole number into whichever number type is needed here".

**Running it:** `learn check` (or `<leader>lc`) compiles your file with a read-only `Test.hs` and prints one line per koan:

```
  ✘ ten is even
      not implemented yet: replace the `undefined`
```

If your file doesn't compile you get GHC's error instead. Read it as *file:line:column*, then **expected** (what the signature promised) vs **actual** (what you wrote):

```
Demo.hs:7:9: error:
    • Couldn't match expected type ‘Double’ with actual type ‘Int’
    • In the first argument of ‘(/)’, namely ‘total’
```

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `+` `-` `*` | arithmetic, usual precedence | `2 + 3 * 4` → `14` |
| `/` | division, fractional types only | `9.0 / 4` → `2.25` |
| `div`, `mod` | whole-number division and remainder | `div 20 6` → `3` |
| ``a `f` b`` | backticks put a two-argument function **between** its arguments | ``20 `div` 6`` means `div 20 6` |
| `++` | join two lists; a `String` is a list of `Char` | `"tea" ++ "pot"` → `"teapot"` |
| `even`, `odd` | built-in (Prelude) functions returning `Bool` | `odd 4` → `False` |
| `Int -> Double` | the type of a function from `Int` to `Double` | `isBig :: Int -> Bool` |
| `fromIntegral n` | whole number → any number type | see below |
| `where` | helper definitions for the equation above it, indented further | see below |

```haskell
tip :: Double
tip = fifteenPercent 40          -- uses the helper defined under `where`
  where
    fifteenPercent :: Int -> Double
    fifteenPercent bill = fromIntegral bill * 0.15   -- 6.0

-- Without fromIntegral, `bill * 0.15` fails:
--   Couldn't match expected type ‘Double’ with actual type ‘Int’
```

## Your task

Edit `Expressions.hs` and replace every `undefined`.

- `secondsPerDay`: hours × minutes × seconds.
- `average`: the average of 3.0, 4.0 and 8.0 (Doubles divide with `/`).
- `greeting`: `"Hello, "` and `"apprentice"` glued together with `++`.
- `tenIsEven`: use the Prelude function `even`.
- `remainder`: 17 modulo 5. Any function can be used infix with backticks: ``a `mod` b``.
- `halfOfSeven`: the `Int` 7 divided by 2 as a `Double`. You'll need `fromIntegral`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

expressions, Int/Double/String/Bool, infix functions, fromIntegral
