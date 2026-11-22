# Koan 23 · BOSS: The Bank of Lambda

> The monastery opens a bank. Every transaction is a value, every failure is a value, and the ledger can never go negative.

**Why it matters:** This boss combines everything: types that model the domain, `Either` for rules that can fail, `Map` for state, and `foldM` to run a whole history of transactions purely, with no mutation.

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
