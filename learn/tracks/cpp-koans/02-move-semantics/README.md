# 02 · Move semantics and the rule of five

## Why it matters
Moving transfers ownership instead of copying it: it's why returning a huge vector by value is cheap. Writing one by hand shows what std::vector and std::unique_ptr do for you.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `T&&` | rvalue reference: binds to temporaries and to things you `std::move` | `void take(std::string&& s);` |
| `std::move(x)` | a cast meaning "you may steal from `x`" (moves nothing by itself) | `auto b = std::move(a);` |
| `T(T&& other)` | move constructor: take `other`'s resources, leave it empty | see below |
| `T& operator=(T&& other)` | move assignment: free what you own, then steal; return `*this` | |
| `= delete` | this function must not exist (e.g. copying) | `Fd(const Fd&) = delete;` |
| `noexcept` | promises not to throw; `std::vector` only moves elements whose move is `noexcept` | `Fd(Fd&&) noexcept;` |
| `std::exchange(x, v)` | set `x = v`, return the old `x` | `int old = std::exchange(n, 0);` |
| `[[nodiscard]]` | warn when a caller ignores the return value | `[[nodiscard]] int get() const;` |
| `static_assert(cond, "msg")` | compile-time check (test.cpp uses it with type traits) | `static_assert(sizeof(int) == 4);` |
| `v.emplace_back(args...)` | construct the element directly inside the vector | `names.emplace_back(3, 'x');  // "xxx"` |

**Rule of five:** if a class owns a raw resource, it needs a destructor plus copy ctor/assign and move ctor/assign
(each either written or `= delete`d). Prefer the rule of zero: hold the resource in a type that already does this.

```cpp
class Fd {                                   // owns an OS file descriptor
public:
    explicit Fd(int fd) : fd_{fd} {}
    Fd(const Fd&) = delete;                  // one owner only
    Fd(Fd&& other) noexcept : fd_{std::exchange(other.fd_, -1)} {}   // steal, leave other empty
private:
    int fd_;
};
```

## Your task
`Buffer` owns a heap array. Make it movable (noexcept), non-copyable, and leave moved-from buffers empty (`size() == 0`, `data() == nullptr`). AddressSanitizer will catch double frees.

Edit `koan.cpp` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types
- `grd` jumps into the standard library headers; `<C-o>` comes back
- `gra` code actions (add includes, fix-its); `]d` next diagnostic
- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug
