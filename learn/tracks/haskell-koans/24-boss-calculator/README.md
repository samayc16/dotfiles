# Koan 24 · BOSS: The Calculator Shrine

> The final shrine holds a broken calculator. The tokenizer still works. Rebuild the parser and the evaluator to ascend.

**Why it matters:** Parsing and evaluating a tiny language is the classic Haskell showcase: a recursive data type mirrors the grammar, and each grammar rule becomes one small function.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `s@(c : cs)` | as-pattern: name the whole value `s` *and* its parts | `dupFirst all@(x : _) = x : all` |
| `span p xs` | split into (longest prefix where `p` holds, rest) | `span isDigit "42+1"` → `("42","+1")` |
| `read s` | parse a `String` into the needed type (crashes on bad input) | `(read "42" :: Int)` |
| `(x :)` | section of `:`, "put x in front" | `(0 :) <$> Just [1]` → `Just [0,1]` |
| `rest'` | `'` is just part of a name: "the next version of rest" | |
| `(TPlus : rest)` | a list pattern can also check the first element's constructor | |
| `(a, b) <- m` | in a `do` block, unpack a tuple result | |
| `uncurry f (a, b)` | call a 2-argument function with a pair | `uncurry max (3, 8)` → `8` |
| mutual recursion | functions may call each other (atom → sum → product → atom) | |

```haskell
data Tok = TInt Int | TComma deriving (Show, Eq)

-- "1,2,3" as tokens → their sum plus the leftover tokens, read left to right
sumList :: [Tok] -> Either String (Int, [Tok])
sumList (TInt n : rest) = go n rest
  where
    go acc (TComma : TInt m : rest') = go (acc + m) rest'
    go acc rest' = Right (acc, rest')
sumList _ = Left "expected a number"
```

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
