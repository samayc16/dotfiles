# Koan 14 · Type classes & instances

> Coins arrive from distant villages. Teach Haskell how to show, compare and describe them.

**Why it matters:** Type classes are Haskell's interfaces (Python protocols, Swift protocols, C++ concepts). Writing an instance teaches existing functions like `sort` and `maximum` to work with your types.

## Your task

Edit `Classes.hs` and replace every `undefined`.

- `instance Show Coin`: `"1¢"`, `"5¢"`, `"10¢"`, `"25¢"`.
- `value`: cents per coin.
- `instance Ord Coin`: compare by value (`comparing value` from Data.Ord).
- `Describable` instances: `describe True == "yes"`, `describe Dime == "a coin worth 10 cents"`, and lists join with `", "`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

type classes, instance declarations, Show, Ord, custom classes
