# Koan 02 · Functions & currying

> The first scroll teaches that every function takes exactly one argument, and returns another function for the rest.

**Why it matters:** Currying is why `map (add 1) xs` just works. Partial application lets you build specialised functions from general ones without writing new code.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `A -> B -> C` | takes an `A`, then a `B`, returns a `C`; the **last** type is the result | `greet :: String -> String -> String` |
| `f a b = …` | several parameters, separated by spaces | `greet title name = title ++ " " ++ name` |
| fewer arguments | **partial application**: you get back a function waiting for the rest | `greetDr = greet "Dr."`, then `greetDr "Who"` → `"Dr. Who"` |
| `a` (lowercase) in a type | type variable: any type, but the same one everywhere it appears | `pickFirst :: a -> a -> a` |
| `(a -> b)` as an argument | parentheses around an arrow: this argument is itself a function | `onFive :: (Int -> Int) -> Int` |
| `sqrt x` | square root of a `Double` | `sqrt 2.25` → `1.5` |
| `-- >>> :t e` | ask GHC for the type of `e` (also `:t e` in ghci) | `:t greet "Dr."` → `String -> String` |

Why partial application works: `A -> B -> C` really means `A -> (B -> C)`. Give it an `A` and you get a `B -> C` back.

```haskell
onFive :: (Int -> Int) -> Int
onFive f = f 5          -- onFive negate → -5
```

## Your task

Edit `Functions.hs` and replace every `undefined`.

- `square 4 == 16`
- `add3 1 2 3 == 6`
- `addTen`: define it by giving `add3` only **two** arguments (no new parameters!).
- `applyTwice f x`: apply `f` to `x`, then apply `f` again: `applyTwice square 3 == 81`.
- `hypotenuse 3 4 == 5.0` (use `sqrt`).

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

function definitions, currying, partial application, higher-order functions
