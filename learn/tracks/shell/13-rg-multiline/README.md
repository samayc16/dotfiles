# Level 13 · Read the tracebacks

> The deploys before the incident failed. Each traceback ends with the line you actually care about.

**Task:** Print the final exception line of every Python traceback in `deploy.log` (e.g. `KeyError: 'DATABASE_URL'`), in order.

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
