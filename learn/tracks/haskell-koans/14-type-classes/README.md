# Koan 14 · Type classes & instances

> Coins arrive from distant villages. Teach Haskell how to show, compare and describe them.

**Why it matters:** Type classes are Haskell's interfaces (Python protocols, Swift protocols, C++ concepts). Writing an instance teaches existing functions like `sort` and `maximum` to work with your types.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `class C a where m :: a -> String` | declare an interface: every type in `C` provides `m` | `class Sized a where size :: a -> Int` |
| `instance C T where m x = …` | make `T` a member by defining the methods (indented) | see below |
| `instance Show T` | write `show` yourself instead of `deriving Show` | see below |
| `instance C a => C [a]` | "a list is in `C` whenever its elements are" | see below |
| `compare a b` | returns `LT`, `EQ` or `GT`; defining it for `Ord` unlocks `<`, `sort`, `maximum` | `compare 2 5` → `LT` |
| `comparing f` | compare two values by `f` | `comparing length "ab" "c"` → `GT` |
| `intercalate sep xs` | join strings with a separator (Python `sep.join(xs)`) | `intercalate "-" ["a", "b"]` → `"a-b"` |

```haskell
class Sized a where
  size :: a -> Int

instance Sized Bool where
  size True  = 1
  size False = 0

instance Sized a => Sized [a] where
  size xs = sum (map size xs)

newtype Temp = Temp Int
instance Show Temp where
  show (Temp d) = show d ++ "°"
```

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
