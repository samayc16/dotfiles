# 17 · Boss: a calculator with variables

## Why it matters
Every earlier koan in one program, the way they meet in real code: enums model the data, `Box` makes the tree recursive, lifetimes let tokens borrow from the source without copying, `Result` and `?` thread errors through a recursive parser without a single `unwrap`, a `HashMap` holds the state, and `Display` turns the tree back into text.

## New syntax
Nothing new: this koan uses what the others taught. A reminder of the pieces:

| Piece | From koan | Here |
|---|---|---|
| enums with data, `match` | 04, 13 | `Token`, `Expr`, `CalcError` |
| `Box` for recursion | 11 | `Expr::Bin(Box<Expr>, char, Box<Expr>)` |
| lifetimes | 10 | `Token<'a>` borrows names from the source; `Parser<'a>` borrows the tokens |
| `Result` + `?` | 05 | every stage returns `Result<_, CalcError>` |
| `Peekable` iterators | 08 | `src.char_indices().peekable()`: look at the next char without consuming it |
| `HashMap` | 09 | the variables |
| `Display` | 05, 06 | print an `Expr` back as fully parenthesised text |
| slice patterns, `@` | 13 | `[Ident(name), Assign, rest @ ..]`, `Op(op @ ('+' \| '-'))` |
| `while let` | | loop while a pattern matches: `while let Some(&(i, c)) = chars.peek() { … }` |

The grammar, loosest first (each rule calls the next one):

```
expr  := term (('+' | '-') term)*        left-associative: 8 - 3 - 2 = (8 - 3) - 2
term  := unary (('*' | '/') unary)*
unary := '-' unary | atom
atom  := number | identifier | '(' expr ')'
```

## Your task
Four stages, checked separately so you can go one at a time:

1. `tokenize`: `"x1 = 2.5*(y+10)"` → `[Ident("x1"), Assign, Num(2.5), Op('*'), LParen, Ident("y"), Op('+'), Num(10.0), RParen]`. A number is digits and dots (`"1.2.3"` → `BadNumber`); an identifier is a letter or `_` then letters, digits or `_`; anything else → `BadChar`
2. the parser: `expr`, `term`, `unary`, `atom` (see the grammar above). `parse_all` and `parse` are written for you
3. `Expr::eval` (`UnknownVar`, `DivByZero`) and `Display` for `Expr`: `"(1 + (2 * 3))"`, `"-x"`, numbers as `f64` prints them
4. `Calculator::run`: evaluate a line; `name = expr` also stores the value, and a failing line changes nothing

Edit `src/lib.rs` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)
- The checks are ordinary Rust tests in `tests/checks.rs`: read them to see exactly what's expected. `cargo test` works in the workspace too (`learn check` always runs the original copy)

## Nvim tips
- `K` shows a symbol's type and docs (rust-analyzer); `grd` jumps to definitions, even into std's source
- `]d` next diagnostic · `<leader>ce` explains the error code (`rustc --explain`) · `<leader>cE` shows the full compiler message
- `gra` code actions: fill match arms, add missing fields or trait items, import a name
- `<leader>th` toggles inlay hints (inferred types, elided lifetimes) · `<leader>cm` expands a macro
- `<leader>rn` runs one check from `tests/checks.rs` (runnables) · `<leader>dn` debugs it
