# Level 24 · Hotfix the config

> Root cause: web is on the wrong port with debug off. Fix the file **in place**, like you would on the box.

**Task:** Edit `./services.conf` in place so that, **in the `[web]` section only**, `port = 8080` and `debug = true`. The `[worker]` section's `debug` must stay `false`. Leave no backup file behind.

**Input** `$DATA/services.conf` (first lines):
```text
# Nimbus service configuration
# Read once at boot. Restart the service after editing.
```

**Expected result (the edited file)** (first lines):
```text
# Nimbus service configuration
# Read once at boot. Restart the service after editing.

[web]
host = 0.0.0.0
port = 8080
```
_29 lines in total._

**Portability trap:** macOS (BSD) sed needs `sed -i '' ...`, GNU sed wants `sed -i ...`. `sed -i.bak ...` works on both: it keeps a backup, which you then delete.

The checker runs your script in a scratch directory containing a fresh `services.conf`, then compares the edited file. Your workspace has its own copy to experiment on.

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 220 characters**, counting code only (comments and the indentation don't count).
- Concepts: `sed -i (BSD vs GNU)`, `ranges + several commands`
