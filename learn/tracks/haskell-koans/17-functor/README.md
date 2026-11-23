# Koan 17 · Functor: mapping inside a box

> Every container in the monastery, whether box, pair or tree, can have its contents transformed without being opened.

**Why it matters:** `fmap` generalises `map` to *any* container: Maybe, Either, IO, trees. Writing Functor instances is the first step toward Applicative and Monad.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `data Box a = Box a` | a type with a **type parameter**: `Box Int`, `Box String`, … | `data Tagged a = Tagged String a` |
| recursive type | a constructor may contain the type itself | `data Chain a = End \| Link a (Chain a)` |
| `fmap f x` | apply `f` inside a container, keeping its shape | `fmap (+ 1) (Just 2)` → `Just 3` |
| `f <$> x` | infix `fmap` | `negate <$> [1, 2]` → `[-1,-2]` |
| `instance Functor Box` | `Box`, not `Box a`: Functor is about the container, not its contents | |
| `Functor f => f Int` | `f` is *any* container type; `f Int` is it holding `Int`s | `showAll :: Functor f => f Int -> f String` |

```haskell
data Tagged a = Tagged String a deriving (Show)

instance Functor Tagged where
  fmap f (Tagged label x) = Tagged label (f x)   -- change the contents, keep the label

data Chain a = End | Link a (Chain a) deriving (Show)

instance Functor Chain where
  fmap _ End         = End
  fmap f (Link x xs) = Link (f x) (fmap f xs)    -- recurse into the rest
```

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
