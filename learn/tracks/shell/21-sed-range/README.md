# Level 21 · Just the database bits

> The DBA asks: "what does the database section say?"

**Task:** Print the `[database]` section of `services.conf`: its header and its lines, but not the blank line after it.

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
