# Koan 22 · Strings & ciphers

> A scroll arrives in code. Build the decoder ring before the messenger leaves.

**Why it matters:** Since `String` is `[Char]`, every list tool you've learned works on text. Data.Char supplies the character-level helpers.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `ord c`, `chr n` | a `Char`'s code number, and back | `ord 'a'` → `97`, `chr 98` → `'b'` |
| `isLower`, `isUpper` | `Char` tests | `isUpper 'Q'` → `True` |
| `mod` with negatives | the result has the divisor's sign, so wrapping works both ways | ``(-3) `mod` 26`` → `23` |
| `reverse` | reverse a list (so also a `String`) | `reverse "abc"` → `"cba"` |
| `unwords` | join words with single spaces (opposite of `words`) | `unwords ["a", "b"]` → `"a b"` |
| `String` = `[Char]` | every list function works on text | `map succ "HAL"` → `"IBM"` |

```haskell
-- rotate a digit character by k, wrapping 9 → 0
spinDigit :: Int -> Char -> Char
spinDigit k c = chr (ord '0' + (ord c - ord '0' + k) `mod` 10)
-- spinDigit 3 '8' → '1'
```

## Your task

Edit `Ciphers.hs` and replace every `undefined`.

- `caesar n`: shift letters by `n` (wrapping, keeping case); leave everything else alone. Negative shifts decode.
- `rot13`: `caesar 13`, its own inverse.
- `isPalindrome`: ignore case and non-letters.
- `capitalizeWords "the way of lambda" == "The Way Of Lambda"`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

Data.Char, ord/chr, String as [Char], words/unwords
