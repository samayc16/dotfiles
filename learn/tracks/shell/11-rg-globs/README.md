# Level 11 · Not the tests

> Count the FIXMEs per file, but leave the test files out of it.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `rg -c` | count matching lines **per file**, printed as `path:count` | `rg -c TODO` → `draft.md:2`, `run.py:1` |
| `-g 'GLOB'` | only search paths that match the glob | `rg -c TODO -g '*.md'` → `draft.md:2` |
| `-g '!GLOB'` | skip paths that match the glob | `rg TODO -g '!*.md'` |
| glob `*` | in a glob, `*` means "any text" (a regex would say `.*`) | `*_old.*` = names containing `_old.` |
| quoting | quote globs, or the shell expands `*` (and `!`) before rg sees them | |

_Examples use level 10's made-up folder: `draft.md` has 2 TODOs, `run.py` has 1._

## Your task

From inside `$DATA/src`, print `path:count` of `FIXME` occurrences for every file **except** test files (names containing `_test.`).

**Input:** the source tree in `$DATA/src` (`ls -R "$DATA/src"` to look around).

**Expected result**:
```text
worker/jobs.go:1
api/handlers.py:1
web/app.js:2
```
_3 lines in total._

_Line order is ignored when checking._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 134 characters**, counting code only (comments and the indentation don't count).
- Concepts: `rg -g '!glob'`, `rg -c`
