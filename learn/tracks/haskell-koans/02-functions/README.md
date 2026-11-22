# Koan 02 · Functions & currying

> The first scroll teaches that every function takes exactly one argument, and returns another function for the rest.

**Why it matters:** Currying is why `map (add 1) xs` just works. Partial application lets you build specialised functions from general ones without writing new code.

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
