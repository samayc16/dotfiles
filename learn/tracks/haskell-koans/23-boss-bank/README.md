# Koan 23 · BOSS: The Bank of Lambda

> The monastery opens a bank. Every transaction is a value, every failure is a value, and the ledger can never go negative.

**Why it matters:** This boss combines everything: types that model the domain, `Either` for rules that can fail, `Map` for state, and `foldM` to run a whole history of transactions purely, with no mutation.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `type Accounts = Map String Int` | type synonym: just another name for an existing type | `type Name = String` |
| `Map.lookup k m` | `Just v` or `Nothing` | |
| `Map.insert k v m` | a new map with `k` set to `v` (replacing any old value) | |
| `Map.member k m` | is `k` a key? | |
| `Map.empty`, `Map.null`, `Map.toAscList` | the empty map / is it empty? / its pairs sorted by key | |
| `when cond (Left e)` | inside an `Either` `do` block: stop with `e` if `cond` holds | add `when` to the `import Control.Monad (…)` line |
| `foldM f start xs` | `foldl` where each step may fail; the first `Left` stops it | see below |

```haskell
-- one shop step: fetch, check, update. Any Left stops it.
sell :: Map String Int -> String -> Either String (Map String Int)
sell stock item = do
  n <- maybe (Left ("unknown " ++ item)) Right (Map.lookup item stock)
  when (n < 1) (Left ("sold out: " ++ item))
  pure (Map.insert item (n - 1) stock)

-- a whole history: foldM sell stock ["tea", "tea", "mochi"]
```

## Your task

Edit `Bank.hs` and replace every `undefined`.

Implement `apply` with these rules (check them in this order):

| Transaction | Errors |
|---|---|
| `Open name` | `AlreadyExists name` |
| `Deposit name amt` | `InvalidAmount amt` if amt ≤ 0, `NoSuchAccount name` |
| `Withdraw name amt` | `InvalidAmount`, `NoSuchAccount`, `InsufficientFunds name balance` |
| `Transfer from to amt` | `InvalidAmount`, `NoSuchAccount from`, `NoSuchAccount to`, `InsufficientFunds from balance` |

New accounts start at 0. Then:

- `applyAll`: apply a list of transactions to an empty bank (`foldM`); stop at the first error.
- `richest`: the `(name, balance)` with the most money.
- `statement`: `["ada: 120", "bo: 5"]`, sorted by name.

## Try it

- `learn check` (or `<leader>lc` in nvim) runs the koans and shows ✔ / ✘ for each.
- Hover any name with `K` to see its type. HLS underlines type errors as you type.
- Lines like `-- >>> expr` are live: put the cursor on one and press `<leader>cl` (HLS eval).
- `<leader>ro` → **ghci: load current file** opens a REPL with your module loaded (`:r` reloads).

## Concepts

ADTs, Either for errors, Data.Map, foldM, modelling a domain
