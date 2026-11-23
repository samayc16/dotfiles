# 02 · Pointers and arrays

## Why it matters
Pointers are C's superpower and its sharpest edge. Understanding that arrays decay to pointers, and walking memory with pointer arithmetic, is the foundation for everything else in C.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `int *p` | `p` holds the address of an `int` | `int *cursor;` |
| `&x` | the address of `x` | `int n = 5; int *p = &n;` |
| `*p` | the `int` that `p` points at, to read or write | `*p = 6;` → now `n == 6` |
| `xs + i` | pointer arithmetic: `i` *elements* further on, not bytes | `*(xs + 2)` is `xs[2]` |
| `p < xs + n` | compare pointers into one array; `xs + n` is one-past-the-end: fine to compare, never to dereference | |
| array → pointer | passing an array passes a pointer to its first element; the length is lost, so it travels as `n` | `total(prices, 4)` |
| `a, b` in a `for` | the comma lets one `for` set up or step two variables | `for (i = 0, j = 9; i < j; i++, j--)` |
| `long` | an integer at least as wide as `int` (64-bit here) | `long big = 3'000'000'000;` |

```c
// count zeros by walking a pointer instead of an index
size_t zeros(const int *xs, size_t n) {
    size_t z = 0;
    for (const int *p = xs; p < xs + n; p++) {
        if (*p == 0) z++;
    }
    return z;
}
```

## Your task
Implement `swap`, `sum`, `reverse` (in place) and `max_element` (returns a pointer to the largest element).

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
