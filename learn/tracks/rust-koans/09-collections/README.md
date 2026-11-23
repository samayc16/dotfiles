# 09 · Collections: HashMap, BTreeMap, HashSet and UTF-8 strings

## Why it matters
`Vec`, `HashMap`, `HashSet` and the B-tree collections cover nearly every data-structure need, and their APIs are built around ownership: `entry` gives you a mutable slot in one lookup, `retain` filters in place. Strings are always valid UTF-8, so the byte-vs-character distinction C lets you ignore is front and centre.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `HashMap<K, V>` | a hash table (unordered, like `std::unordered_map`) | `let mut ages: HashMap<String, u32> = HashMap::new();` |
| `map.entry(k).or_insert(v)` | `&mut V` for key `k`, inserting `v` first if it's missing: one lookup | `*hits.entry(page).or_insert(0) += 1;` |
| `.or_default()` | the same, inserting `V::default()` (0, an empty Vec, …) | `groups.entry(key).or_default().push(x);` |
| `map.get(&k)` | `Option<&V>` | |
| `BTreeMap`, `BTreeSet` | sorted by key (like `std::map`) | |
| `HashSet<T>`, `set.insert(x)` | `insert` returns `true` if `x` was new | |
| `v.retain(\|x\| …)` | keep only the elements the closure approves (it may be `FnMut`) | `v.retain(\|&n\| n != 0);` |
| `v.sort_by(\|a, b\| …)` | sort with a comparator returning an `Ordering` | `v.sort_by(\|a, b\| b.score.cmp(&a.score));` |
| `a.cmp(&b).then_with(\|\| …)` | compare by one key, then break ties with another | |
| `v.truncate(n)` | keep the first `n` | |
| `s.chars()` | the Unicode characters (`char`); `s.len()` counts BYTES | `"é".len()` → `2`, `"é".chars().count()` → `1` |
| `.rev()` | reverse an iterator | |
| `s.trim_matches(\|c: char\| …)` | strip matching chars from both ends | `"--x--".trim_matches('-')` → `"x"` |
| `c.is_alphanumeric()`, `s.to_lowercase()` | Unicode-aware | |
| `HashMap::from([(k, v), …])` | build a map from an array of pairs | |

## Your task
- `word_counts`: lowercase words, punctuation trimmed from both ends, empty words skipped
- `top_words`: the `n` most frequent `(word, count)` pairs, most frequent first, ties alphabetical
- `by_length`: words grouped by length *in characters*, each group sorted
- `dedup_keep_order`: drop repeats in place, keeping each value's first occurrence
- `reverse_chars`: reverse by character, not by byte

Edit `src/lib.rs` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)
- The checks are ordinary Rust tests in `tests/checks.rs`: read them to see exactly what's expected. `cargo test` works in the workspace too (`learn check` always runs the original copy)

## Nvim tips
- `K` shows a symbol's type and docs (rust-analyzer); `grd` jumps to definitions, even into std's source
- `]d` next diagnostic · `<leader>ce` explains the error code (`rustc --explain`) · `<leader>cE` shows the full compiler message
- `gra` code actions: fill match arms, add missing fields or trait items, import a name
- `<leader>th` toggles inlay hints (inferred types, elided lifetimes) · `<leader>cm` expands a macro
- `<leader>rn` runs one check from `tests/checks.rs` (runnables) · `<leader>dn` debugs it
