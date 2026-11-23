# 03 · RAII and smart pointers

## Why it matters
In modern C++ you almost never write new/delete. Ownership lives in the type: unique_ptr for one owner, shared_ptr for many, weak_ptr to observe without owning.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `std::unique_ptr<T>` | the only owner; deletes the object when it goes out of scope; move-only | `std::unique_ptr<Widget> w;` |
| `std::make_unique<T>(args...)` | allocate + construct + wrap, no `new` | `auto p = std::make_unique<std::string>(3, 'z');` |
| `p->m`, `*p`, `if (p)` | use like a raw pointer; empty pointers are false | `p->size()` → `3` |
| `p.get()` | borrow the raw pointer; ownership stays with `p` | `const Widget* raw = w.get();` |
| `std::shared_ptr<T>`, `std::make_shared<T>(...)` | shared, reference-counted owner; `.use_count()` | `auto cfg = std::make_shared<std::string>("dark");` |
| `std::weak_ptr<T>` | watches a shared object without owning it | see below |
| `.lock()`, `.expired()`, `.reset()` | get a temporary shared_ptr (or empty) / is it gone? / drop ownership now | |

```cpp
auto a = std::make_unique<int>(5);
auto b = std::move(a);                    // ownership moves; a == nullptr now

auto cfg = std::make_shared<std::string>("dark");
std::weak_ptr<std::string> watch{cfg};    // does not keep "dark" alive
if (auto alive = watch.lock()) { /* use *alive */ }
cfg.reset();                              // last owner gone: watch.expired() == true
```

## Your task
- `List::push_front` and `length` for a singly-linked list owned by `unique_ptr`s
- `make_observer` returns a weak_ptr that expires when the shared object dies

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
