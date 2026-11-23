# 11 · File I/O

## Why it matters
Reading and writing files, and checking every call that can fail, is everyday systems programming. It's also the C behind every shell tool you use.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `FILE *f = fopen(path, mode)` | open a file: `"r"` read, `"w"` write (truncates), `"a"` append; returns `nullptr` on failure, so always check | `FILE *log = fopen("app.log", "a");` |
| `fclose(f)` | flush and close; returns 0 on success (a failed write often only shows up here) | `if (fclose(log) != 0) ...` |
| `fprintf(f, fmt, ...)` | `printf` into a file | `fprintf(log, "%s=%d\n", key, val);` |
| `fgets(buf, size, f)` | read one line (at most `size - 1` chars, keeps the `'\n'`); returns `nullptr` at end of file | see below |
| `fscanf(f, "%ld", &n)` | parse from a file; returns how many items it converted (1 = got one; 0 or `EOF` = stop) | |
| `%ld` | `long` in printf / scanf formats | `printf("%ld", total);` |
| `strchr(s, c)` | pointer to the first `c` in `s`, or `nullptr` | `strchr("k=v", '=')` |
| `const char *const *p` | pointer to read-only pointers to read-only chars: an array of strings you won't change | `const char *const days[] = {"mon", "tue"};` |

```c
// print every line of a file with its number
FILE *f = fopen(path, "r");
if (f == nullptr) { perror(path); return -1; }
char line[128];
for (int i = 1; fgets(line, sizeof line, f) != nullptr; i++) {
    printf("%d: %s", i, line);    // line already ends with '\n'
}
fclose(f);
```

## Your task
Implement `write_lines`, `count_lines` (-1 if the file can't be opened) and `sum_numbers` (sums whitespace-separated integers).

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
