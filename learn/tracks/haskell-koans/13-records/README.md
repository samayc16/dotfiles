# Koan 13 · Records

> The monastery keeps a ledger of monks: their name, belt and experience. Time to automate the promotions.

**Why it matters:** Records give fields names, generate accessor functions, and offer *update syntax* (`m { xp = 10 }`) that returns a new value. Nothing is mutated, like a frozen dataclass.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `data Cat = Cat { catName :: String, lives :: Int }` | record: a constructor with named fields | |
| `lives c` | every field name is also a getter function | `lives tom` → `9` |
| `Cat { catName = "Tom", lives = 9 }` | build a record by field name | |
| `c { lives = 8 }` | update syntax: a **copy** with some fields changed; the original is untouched | `tom { lives = lives tom - 1 }` |
| `deriving Ord` | constructors compare in the order they are declared | `Small < Large` → `True` |
| `succ x` | the next value of an `Enum` type | `succ Small` → `Medium` |
| `maxBound` | the last value of a `Bounded` type (type comes from context) | `(maxBound :: Size)` → `Large` |

```haskell
data Size = Small | Medium | Large
  deriving (Show, Eq, Ord, Enum, Bounded)
```

## Your task

Edit `Records.hs` and replace every `undefined`.

- `newMonk "ada"`: White belt, 0 xp.
- `train n m`: add `n` xp (use record update syntax).
- `promote m`: next belt; Black stays Black.
- `ready m`: at least 100 xp.
- `graduates ms`: names of every monk who is `ready`.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

record syntax, field accessors, record update, Ord/Enum on enums, succ
