# Koan 22 · Strings & ciphers

> A scroll arrives in code. Build the decoder ring before the messenger leaves.

**Why it matters:** Since `String` is `[Char]`, every list tool you've learned works on text. Data.Char supplies the character-level helpers.

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
