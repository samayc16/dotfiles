# Level 11 · Not the tests

> Count the FIXMEs per file, but leave the test files out of it.

**Task:** From inside `$DATA/src`, print `path:count` of `FIXME` occurrences for every file **except** test files (names containing `_test.`).

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
