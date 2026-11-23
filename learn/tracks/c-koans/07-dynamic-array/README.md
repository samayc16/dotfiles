# 07 · Dynamic memory: a growable vector

## Why it matters
Every language's list/vector is this under the hood. Writing one teaches allocation, growth strategy and ownership, and the sanitizer shows you instantly when you get it wrong.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `p->f` | member through a pointer, same as `(*p).f` | `acct->balance += 10;` |
| `x++` in an expression | uses the old value, then increments | `buf[len++] = c;` appends, then bumps `len` |
| `malloc(bytes)`, `free(p)` | allocate / release heap memory (`<stdlib.h>`); `free(nullptr)` is a safe no-op | `double *xs = malloc(10 * sizeof *xs);` |
| `realloc(p, bytes)` | resize a block; it may MOVE it, so it returns the new address, or `nullptr` on failure (the old block is still valid) | see below |
| `sizeof *p` | size of what `p` points at; stays correct if `p`'s type changes | `malloc(n * sizeof *p)` |
| `c ? a : b` | ternary: `a` if `c` is true, else `b` | `size_t cap = want ? want : 16;` |
| `*v = (struct T){0};` | overwrite a whole struct through a pointer | |

```c
// never assign realloc's result straight back: on failure you'd lose the old block
char *bigger = realloc(buf, new_size);
if (bigger == nullptr) {
    return false;       // buf is untouched and still yours to free
}
buf = bigger;
```

## Your task
Implement `vec_push` (grow by doubling with realloc, return false if allocation fails), `vec_get` (bounds-checked, nullptr when out of range) and `vec_free`.

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
