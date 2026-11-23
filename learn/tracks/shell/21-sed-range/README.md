# Level 21 · Just the database bits

> The DBA asks: "what does the database section say?"

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sed -n '...p'` | `-n`: print nothing unless told to; `p`: print this line | `printf 'l1\nl2\nl3\n' \| sed -n '2p'` → `l2` |
| `2,4p`, `/re/p` | address lines by number range / by regex | `sed -n '/tea/p'` acts like `grep tea` |
| `/A/,/B/` | a range: from a line matching A through the next line matching B | `printf 'a\nSTART\nb\nEND\nc\n' \| sed -n '/START/,/END/p'` → `START`, `b`, `END` |
| `ADDR{cmd;}` | run commands only on the addressed lines; end each with `;` | `sed -n '/A/,/B/{/x/p;}'` |
| `\[` | a literal `[` (a bare `[` starts a class) | `sed -n '/^\[a\]/p'` matches the line `[a]` |

## Your task

Print the `[database]` section of `services.conf`: its header and its lines, but not the blank line after it.

**Input** `$DATA/services.conf` (first lines):
```text
# Nimbus service configuration
# Read once at boot. Restart the service after editing.
```

**Expected result**:
```text
[database]
host = db.internal.example
port = 5432
user = nimbus
pool_size = 20   # max open connections
timeout = 30
```
_6 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 149 characters**, counting code only (comments and the indentation don't count).
- Concepts: `sed -n ... p`, `address ranges /a/,/b/`
