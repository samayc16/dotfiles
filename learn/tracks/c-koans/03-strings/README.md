# 03 · Strings, safely

## Why it matters
Most famous C security bugs are string overflows. Bounded APIs like snprintf, plus a sanitizer that screams on overflow, are how professionals write string code.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `'\0'` | the NUL char that ends every C string | `"hi"` is 3 bytes: `'h' 'i' '\0'` |
| `const char *s` | a read-only string: a pointer to its first char | `const char *tool = "awk";` |
| `char buf[] = "..."` | a writable copy in an array (a string literal itself is read-only) | `char word[] = "sed"; word[0] = 'S';` |
| `p - s` | subtracting two pointers into one array gives the distance in elements; cast it with `(size_t)` | |
| `snprintf(dst, cap, fmt, ...)` | `printf` into `dst`, writing at most `cap - 1` chars plus `'\0'`; returns the length it *wanted* | `snprintf(b, 4, "%d", 12345)` → `b` is `"123"`, returns `5` |
| `sizeof buf` | bytes in an array variable (no parentheses needed for variables) | `char b[16];` → `sizeof b` is `16` |
| `isspace`, `toupper` | `<ctype.h>` char tests and conversions; pass `(unsigned char)c`, since a negative `char` is UB | `tolower((unsigned char)'Q')` → `'q'` |
| `strcmp(a, b) == 0` | the two strings are equal (`a == b` only compares addresses) | `strcmp(cmd, "quit") == 0` |

## Your task
- `my_strlen` without calling strlen
- `copy_bounded` copies safely, returns `true` if it had to truncate
- `count_words` counts whitespace-separated words
- `to_upper` uppercases in place

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
