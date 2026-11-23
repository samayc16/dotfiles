# Level 10 · Enter ripgrep

> Maybe the bug is in code. Ripgrep searches whole trees fast and skips junk for you.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `rg PATTERN [DIR]` | ripgrep: search every file under DIR (default: here), skipping hidden and ignored files | `rg install` |
| `-t TYPE` | only files of one type; `rg --type-list` lists them | `rg -t md install` → only Markdown files |
| `-l` | print the names of matching files, not the lines | `rg -l install` → `run.py`, `setup.md` |
| `a && b` | run `b` only if `a` succeeded | `cd /tmp && ls` |
| `.ignore` | a file of gitignore-style paths that rg skips | a line `old/` hides that folder |

_Examples run in a made-up folder: `setup.md`, `run.py`, `draft.md` and an ignored `old/`._

## Your task

From inside `$DATA/src`, list the **Python** files that contain `TODO` (paths relative to `src`, one per line). `vendor/` is listed in `src/.ignore`, so rg skips it: don't fight that.

**Input:** the source tree in `$DATA/src` (`ls -R "$DATA/src"` to look around).

**Expected result**:
```text
api/models.py
api/handlers.py
```
_2 lines in total._

_Line order is ignored when checking._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 123 characters**, counting code only (comments and the indentation don't count).
- Concepts: `rg -t TYPE`, `rg -l`, `.ignore files`
