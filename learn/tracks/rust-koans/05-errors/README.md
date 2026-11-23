# 05 · Errors: Result, ? and your own error type

## Why it matters
Rust has no exceptions. Failure is a return value, so it shows up in the signature and can't be silently ignored, while `?` keeps the happy path as short as exception code. A custom error enum gives callers something to `match` on; `Box<dyn Error>` is the quick 'something went wrong' for applications and tests.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `Result<T, E>` | `Ok(value)` or `Err(error)`; ignoring one is a warning (`#[must_use]`) | `fn parse_age(s: &str) -> Result<u8, String>` |
| `expr?` | `Err(e)`: return `Err(From::from(e))` from this function. `Ok(v)`: the expression is `v` | `let n: u8 = s.parse()?;` |
| `opt.ok_or(err)` | `Option` → `Result`: `None` becomes `Err(err)` | `name.ok_or(FormError::NoName)?` |
| `s.split_once('=')` | `Some((before, after))` at the first `=`, else `None` | `"a:b".split_once(':')` → `Some(("a", "b"))` |
| `s.trim()` | without surrounding whitespace (a sub-slice, no copy) | |
| `s.parse::<u16>()` | text → number, `Err(ParseIntError)` if it isn't one | `"300".parse::<u8>()` is an `Err`: too big |
| `for (i, line) in text.lines().enumerate()` | each line with its 0-based index | |
| `continue` | skip to the next loop iteration | |
| `impl fmt::Display for T` | what `{}` and `.to_string()` print | see below |
| `write!(f, "…", …)` | like `format!`, into the formatter; returns `fmt::Result` | |
| `impl From<A> for B` | the conversion `?` uses to turn an `A` error into your `B` | see below |
| `Box<dyn Error>` | "any error": every type implementing `Error` converts into it | `fn main() -> Result<(), Box<dyn Error>>` |

```rust
#[derive(Debug)]
enum FetchError { Timeout(u32), Reply(ParseIntError) }

impl fmt::Display for FetchError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            FetchError::Timeout(secs) => write!(f, "timed out after {secs}s"),
            FetchError::Reply(e) => write!(f, "bad reply: {e}"),
        }
    }
}

impl From<ParseIntError> for FetchError {
    fn from(e: ParseIntError) -> Self {
        FetchError::Reply(e)
    }
}

fn status_code(reply: &str) -> Result<u32, FetchError> {
    let code: u32 = reply.trim().parse()?; // ParseIntError → FetchError, via From
    Ok(code)
}
```

## Your task
- `Display` for `ConfigError`: `"line 3: expected key=value"`, `"missing key: port"`, `"bad number: <the ParseIntError>"`
- `impl From<ParseIntError> for ConfigError`, so `?` can convert parse errors for you
- `parse_line`: split `key=value` (trimming both parts), or `Malformed(line_no)`
- `get_port`: find `port=…` in a multi-line config (skip blank lines, every other line must parse) and parse it as a `u16`; `Missing("port")` if there's none
- `sum_list`: add up `"1, 2, 39"`, failing on the first bad number (here the error type is `Box<dyn Error>`)

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
