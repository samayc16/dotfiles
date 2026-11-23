# Level 13 · Read the tracebacks

> The deploys before the incident failed. Each traceback ends with the line you actually care about.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-U` | multiline: a pattern may span lines; write the newline as `\n` | `printf 'name:\n  ana\n' \| rg -U -o -r '$1' 'name:\n  (.+)'` → `ana` |
| `.*`, `.+` | any run of characters (zero or more / one or more); `.` never matches a newline | `Trace.*` = the rest of that line |
| `(?:...)` | a group that does **not** capture, so `$1` still points at your real group | `echo 'k: v' \| rg -o -r '$1' '(?:k\|key): (\w+)'` → `v` |
| `(...)+` | repeat a whole group | `echo 'abababc' \| rg -o '(?:ab)+'` → `ababab` |

## Your task

Print the final exception line of every Python traceback in `deploy.log` (e.g. `KeyError: 'DATABASE_URL'`), in order.

**Input** `$DATA/deploy.log` (first lines):
```text
2026-03-14T09:58:00Z deploy start version=2026.03.14-1
2026-03-14T09:58:04Z deploy step=build status=ok
```

**Expected result**:
```text
ConnectionRefusedError: [Errno 61] Connection refused
TimeoutError: migration lock not acquired in 30s
KeyError: 'DATABASE_URL'
PermissionError: [Errno 13] Permission denied: '/var/lib/nimbus/static'
```
_4 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 158 characters**, counting code only (comments and the indentation don't count).
- Concepts: `rg -U multiline`, `non-capturing groups (?:)`
