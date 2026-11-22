# Koan 17 · Functor: mapping inside a box

> Every container in the monastery, whether box, pair or tree, can have its contents transformed without being opened.

**Why it matters:** `fmap` generalises `map` to *any* container: Maybe, Either, IO, trees. Writing Functor instances is the first step toward Applicative and Monad.

## Your task

Edit `Functors.hs` and replace every `undefined`.

- `Functor` instances for `Box`, `Pair` and `Tree`.
- `incAll`: add 1 to every Int inside *any* Functor.
- `lengths`: the length of a `Maybe String`, using `<$>`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

Functor, fmap, <$>, instances for your own types, trees
