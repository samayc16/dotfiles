# 06 · Tagged unions

## Why it matters
Tagged unions are C's version of Rust enums or Swift enums with associated values: one type that can be one of several shapes, with the tag telling you which.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `union { A a; B b; }` | all members share the same bytes; size = the largest member; only the one written last is valid | `union Num { int i; float f; };` |
| anonymous member | a `union {...};` with no member name: its fields are used as if they were the outer struct's | `v.i` instead of `v.u.i` |
| `struct { ... } name;` | an unnamed struct type declared right where it's used as a member | `struct { int w, h; } size;` |
| tag + union | an enum field records which union member is live; check it before reading | see below |
| `.member = {...}` | designated initializers reach into union members too | `(struct Value){.tag = V_INT, .i = 7}` |
| π | `M_PI` isn't standard C (and `koan.c` doesn't include `<math.h>`): write `3.141592653589793` | |

```c
enum ValueTag { V_INT, V_TEXT };
struct Value {
    enum ValueTag tag;
    union { int i; const char *text; };   // anonymous union
};

void print_value(struct Value v) {
    switch (v.tag) {
    case V_INT:  printf("%d\n", v.i); break;
    case V_TEXT: printf("%s\n", v.text); break;
    }
}
```

## Your task
Implement `make_circle`, `make_rect` and `area` for the tagged-union `struct Shape`.

Edit `koan.c` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on a function or type shows its signature/docs (clangd)
- `]d` / `[d` jump between diagnostics; `gra` offers fixes
- `<leader>rr` compiles and runs the current file (C23 + sanitizers)
- `<leader>db` breakpoint, `<leader>dc` debug: step with `<leader>di` / `<leader>do`
