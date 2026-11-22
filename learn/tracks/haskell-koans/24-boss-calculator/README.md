# Koan 24 · BOSS: The Calculator Shrine

> The final shrine holds a broken calculator. The tokenizer still works. Rebuild the parser and the evaluator to ascend.

**Why it matters:** Parsing and evaluating a tiny language is the classic Haskell showcase: a recursive data type mirrors the grammar, and each grammar rule becomes one small function.

## Your task

Edit `Calc.hs` and replace every `undefined`.

`tokenize` is done for you. Implement:

- `eval`: `Left "division by zero"` when dividing by 0 (integer `div`).
- `pretty`: fully parenthesised, e.g. `"(1 + (2 * 3))"`.
- The parser, one function per grammar rule (each returns the parsed `Expr` plus the leftover tokens):
  ```
  sum     = product (('+' | '-') product)*      -- left-associative!
  product = atom    (('*' | '/') atom)*
  atom    = number | '(' sum ')'
  ```
- `calc "2 * (3 + 4) - 10 / 5" == Right 12`

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

recursive ADTs, evaluation, recursive-descent parsing, Either monad
