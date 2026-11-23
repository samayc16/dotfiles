# Level 18 · SHOUTING hostnames

> The inventory file has the same hosts in three different capitalisations.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `tr SET1 SET2` | swap each character of SET1 for the matching one in SET2. Reads stdin only | `echo Hi \| tr 'a-z' 'A-Z'` → `HI` |
| `'[:lower:]'`, `'[:upper:]'` | named character sets in tr | `echo Ab \| tr '[:lower:]' '[:upper:]'` → `AB` |
| `tr -d`, `tr -s` | delete those characters / squeeze repeats into one | `echo a-b-c \| tr -d -` → `abc` |
| `cmd < file` | feed a file into a command's stdin | `sort < list.txt` |

## Your task

Print the distinct hostnames from `hosts.txt`, lowercased, sorted.

**Input** `$DATA/hosts.txt` (first lines):
```text
cache-01.nimbus.example
db-01.nimbus.example
```

**Expected result** (first lines):
```text
api-01.nimbus.example
api-02.nimbus.example
api-03.nimbus.example
api-04.nimbus.example
cache-01.nimbus.example
db-01.nimbus.example
```
_8 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 147 characters**, counting code only (comments and the indentation don't count).
- Concepts: `tr`, `input redirection <`
