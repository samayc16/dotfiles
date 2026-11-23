# 14 · pathlib and the walrus operator

## Why it matters
pathlib replaces os.path string juggling with objects (`folder / 'a.txt'`). The walrus operator assigns inside an expression, which tidies read loops.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `Path(p)` | a path object (`pathlib`) | `Path("logs")` |
| `folder / "a.txt"` | join paths with `/` | `Path("logs") / "today.txt"` |
| `.glob("*.txt")` | iterate matching paths in that folder (`**/*.txt` recurses) | `list(Path(".").glob("*.md"))` |
| `.read_text()`, `.write_text(s)` | the whole file as one `str`; write one `str` | `Path("notes.txt").read_text()` |
| `s.splitlines()` | split into lines, dropping the `\n`s | `"a\nb\n".splitlines()` → `['a', 'b']` |
| `max(xs, key=f, default=v)` | `default` is returned for an empty iterable instead of raising | `max([], default=0)` → `0` |
| `(name := expr)` | walrus: assign AND use the value in one expression (3.8+) | `if (n := len(xs)) > 3: print(n)` |
| `IO[str]`, `stream.read(n)` | a text stream; `read(n)` returns up to `n` chars, `""` at the end | `io.StringIO("hey").read(2)` → `'he'` |

## Your task
- `count_lines(folder, pattern)` sums lines over matching files
- `longest_line(path)` returns the longest line
- `read_chunks(stream, size)` yields chunks using `:=`

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
