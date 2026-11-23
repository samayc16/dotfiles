"""C++26 koans: modern C++ from RAII to concepts, compiled with clang++ -std=c++26 + sanitizers."""

TRACK = {
    "name": "C++ · Koans (C++26)",
    "slug": "cpp-koans",
    "language": "cpp",
    "description": "RAII, move semantics, lambdas, ranges, std::expected, concepts, constexpr and C++26 pack indexing.",
    "file": "koan.cpp",
    "test_file": "test.cpp",
    "checker": "check-cpp.sh",
    "nvim_tips": (
        "- `K` shows types and docs (clangd); `<leader>th` toggles inlay hints to see deduced `auto` types\n"
        "- `grd` jumps into the standard library headers; `<C-o>` comes back\n"
        "- `gra` code actions (add includes, fix-its); `]d` next diagnostic\n"
        "- `<leader>rr` compiles + runs (C++26, ASan/UBSan); `<leader>db` + `<leader>dc` to debug"
    ),
}

PRELUDE = "#include <koan_test.hpp>\n#include <koan.cpp>  // <...> so the workspace copy (-I) wins\n#include <format>\n\n"


def koan(**kwargs):
    kwargs["test"] = PRELUDE + kwargs["test"]
    return kwargs


KOANS = [
    koan(
        slug="modern-basics",
        title="auto, structured bindings, std::format",
        difficulty=1,
        xp=10,
        concepts=["auto", "structured bindings", "range-for", "std::format", "std::minmax_element"],
        hints=[
            "Look at the README's New syntax table: `std::ranges::minmax`, structured bindings, range-for over a map, and the `std::format` width/alignment spec cover all three functions.",
            'min_max: one `std::ranges::minmax` call gives `.min` and `.max`; unpack them and brace-return. total: range-for over the map, unpacking each element into key and value. row: one `std::format` call with a width + alignment per field.',
            'Same ideas on other data: `auto r = std::ranges::minmax(temps); int spread = r.max - r.min;` · `for (const auto& [city, t] : temps) hottest = std::max(hottest, t);` · `std::format("[{:>5}]", 42)` → `[   42]`.',
            'Near-answer: `const auto [lo, hi] = std::ranges::minmax(values); return {lo, hi};` and `std::format("{:<6}|{:>4}", name, count)`.',
        ],
        primer=r"""
## Modern C++ in 2 minutes

**How a koan runs.** `koan.cpp` has no `main`. The read-only `test.cpp` does `#include <koan.cpp>`, calls your
functions and checks the results. The checker compiles both with:

```
clang++ -std=c++26 -Wall -Wextra -g -O0 -fsanitize=address,undefined ...
```

so you get the newest standard library, all common warnings, and AddressSanitizer/UBSan to catch double frees,
use-after-free and overflow at runtime.

**Run it:** `learn check` (or `<leader>lc`). `warning:` lines are fine; each `CHECK` prints one line:

```
  ✗ row("vim", 7) == "vim   |   7" — got 'vim|7'

  0/3 checks passing
```

**A compile error:** read the first `error:` line (file:line:col). The `note:` lines after it point into library
headers and can usually be skipped. Format strings are checked at compile time, so two `{}` with one argument is:

```
koan.cpp:5:24: error: call to consteval function 'std::basic_format_string<char, ...>' is not a constant expression
    5 |     return std::format("{} v{}", tool);
note: ... "Argument index outside the valid range"
```

**Habits this track assumes**

| Habit | Why |
|---|---|
| take inputs as `const T&` (or a view, koan 09) | no copy, no mutation |
| brace-initialise: `int n{0};`, `return {a, b};` | no silent narrowing; works for every type |
| `auto` when the type is obvious or unspeakable | less noise; `K` or inlay hints show the real type |
| no raw `new`/`delete` (except koan 02) | ownership lives in types (koan 03) |
| `(void)x;` in starters | silences "unused parameter"; delete it once you use `x` |
""",
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `auto x = expr;` | type deduced from the initializer | `auto ratio = 0.75;  // double` |
| `return {a, b};` | brace-initialise the declared return type | `std::pair<char, int> grade() { return {'A', 93}; }` |
| `const auto [a, b] = pair_or_struct;` | structured binding: unpack members into names | `const auto [letter, score] = grade();` |
| `for (const auto& x : container)` | range-for; `const auto&` = read-only, no copy | `for (const auto& w : words) ...` |
| `std::ranges::minmax(r)` | smallest and largest in one pass, as `.min` / `.max` | `std::ranges::minmax(std::vector{7, 2, 9}).max` → `9` |
| `std::format("{:>5}", x)` | Python-style formatting; `<` left, `>` right, `^` centre, number = width | `std::format("[{:>5}]", 42)` → `"[   42]"` |
| `{{` `}}` | literal braces inside a format string (used by test.cpp) | `std::format("{{{}}}", 1)` → `"{1}"` |

```cpp
std::map<std::string, int> temps{{"oslo", 4}, {"lima", 19}};
int hottest = 0;
for (const auto& [city, t] : temps) {   // each element is a std::pair<const std::string, int>
    if (t > hottest) hottest = t;
}
```
""",
        why="Modern C++ reads like a scripting language when you let the compiler deduce types and destructure values: less noise, fewer bugs.",
        task="- `min_max` returns {smallest, largest}\n- `total` sums the map's values using structured bindings\n- `row` formats like `vim   |   7` (name left-aligned in 6, count right-aligned in 4)",
        code="""
#include <algorithm>
#include <format>
#include <map>
#include <string>
#include <utility>
#include <vector>

std::pair<int, int> min_max(const std::vector<int>& values) {
    //>> return {0, 0};  // TODO: std::ranges::minmax + structured bindings
    const auto [lo, hi] = std::ranges::minmax(values);
    return {lo, hi};
    //<<
}

int total(const std::map<std::string, int>& counts) {
    //>> return 0;
    int sum = 0;
    for (const auto& [name, count] : counts) {
        sum += count;
    }
    return sum;
    //<<
}

std::string row(const std::string& name, int count) {
    //>> return name + "|" + std::to_string(count);
    return std::format("{:<6}|{:>4}", name, count);
    //<<
}
""",
        test="""
int main() {
    const auto [lo, hi] = min_max({4, -2, 9, 0});
    CHECK(lo == -2 && hi == 9, std::format("got {{{}, {}}}", lo, hi));
    CHECK(total({{"vim", 7}, {"awk", 3}}) == 10, "sum of values");
    CHECK(row("vim", 7) == "vim   |   7", std::format("got '{}'", row("vim", 7)));
    return koan_finish();
}
""",
    ),
    koan(
        slug="move-semantics",
        title="Move semantics and the rule of five",
        difficulty=3,
        xp=30,
        concepts=["move constructor", "move assignment", "noexcept", "std::exchange", "deleted copy"],
        hints=[
            "Read the New syntax table (`&&`, `std::move`, `= delete`, `noexcept`, `std::exchange`). The static_assert message and ASan's double-free report tell you what is missing.",
            'Without a move constructor, `Buffer b{std::move(a)}` copies the raw pointer: two owners, two `delete[]`s. A move must steal pointer + size and leave `other` as {nullptr, 0}. Also `= delete` both copy operations, and mark the moves `noexcept`.',
            'Move assignment on another class: `Fd& operator=(Fd&& o) noexcept { if (this != &o) { release_mine(); fd_ = std::exchange(o.fd_, -1); } return *this; }`',
            'Near-answer: `Buffer(Buffer&& other) noexcept : data_{std::exchange(other.data_, nullptr)}, size_{std::exchange(other.size_, 0)} {}`, `Buffer(const Buffer&) = delete;`, and a move-assign that does `delete[] data_;` before stealing.',
        ],
        syntax=r"""
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
""",
        why="Moving transfers ownership instead of copying it: it's why returning a huge vector by value is cheap. Writing one by hand shows what std::vector and std::unique_ptr do for you.",
        task="`Buffer` owns a heap array. Make it movable (noexcept), non-copyable, and leave moved-from buffers empty (`size() == 0`, `data() == nullptr`). AddressSanitizer will catch double frees.",
        code="""
#include <cstddef>
#include <utility>

class Buffer {
public:
    explicit Buffer(std::size_t size) : data_{new int[size]{}}, size_{size} {}
    ~Buffer() { delete[] data_; }

    //>> // TODO: move constructor, move assignment (noexcept); delete the copy operations
    Buffer(const Buffer&) = delete;
    Buffer& operator=(const Buffer&) = delete;

    Buffer(Buffer&& other) noexcept
        : data_{std::exchange(other.data_, nullptr)}, size_{std::exchange(other.size_, 0)} {}

    Buffer& operator=(Buffer&& other) noexcept {
        if (this != &other) {
            delete[] data_;
            data_ = std::exchange(other.data_, nullptr);
            size_ = std::exchange(other.size_, 0);
        }
        return *this;
    }
    //<<

    [[nodiscard]] std::size_t size() const { return size_; }
    [[nodiscard]] int* data() const { return data_; }

private:
    int* data_;
    std::size_t size_;
};
""",
        test="""
#include <type_traits>
#include <vector>

static_assert(!std::is_copy_constructible_v<Buffer>, "Buffer owns memory: delete its copy constructor");

int main() {
    Buffer a{8};
    a.data()[3] = 42;
    Buffer b{std::move(a)};
    CHECK(b.size() == 8 && b.data()[3] == 42, "b took over a's array");
    CHECK(a.size() == 0 && a.data() == nullptr, "moved-from a is empty");
    Buffer c{2};
    c = std::move(b);
    CHECK(c.size() == 8 && b.data() == nullptr, "move assignment transfers ownership");
    CHECK(std::is_nothrow_move_constructible_v<Buffer>, "mark the move constructor noexcept (std::vector relies on it)");
    std::vector<Buffer> many;
    for (int i = 0; i < 20; ++i) many.emplace_back(4);  // reallocations move, never copy
    CHECK(many.size() == 20, "vector of move-only Buffers");
    return koan_finish();
}
""",
    ),
    koan(
        slug="smart-pointers",
        title="RAII and smart pointers",
        difficulty=2,
        xp=25,
        concepts=["std::unique_ptr", "std::make_unique", "std::shared_ptr", "std::weak_ptr", "ownership"],
        hints=[
            'New syntax table: `std::make_unique`, `std::move` of a unique_ptr, `.get()`, and `std::weak_ptr`. You never write `new` or `delete` in this koan.',
            'push_front: make a new node, give it the old head (move), then make it the head (move). length: walk with a plain `const Node*` starting at `head.get()` until nullptr. make_observer: a weak_ptr can be built straight from a shared_ptr.',
            "On other data: `auto a = std::make_unique<int>(5); auto b = std::move(a);  // a is now nullptr` · `std::weak_ptr<Config> w{cfg};` doesn't raise `cfg.use_count()`.",
            'Near-answer: `auto node = std::make_unique<Node>(value); node->next = std::move(head); head = std::move(node);` · `for (const Node* n = head.get(); n != nullptr; n = n->next.get()) ++count;` · `return shared;`',
        ],
        syntax=r"""
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
""",
        why="In modern C++ you almost never write new/delete. Ownership lives in the type: unique_ptr for one owner, shared_ptr for many, weak_ptr to observe without owning.",
        task="- `List::push_front` and `length` for a singly-linked list owned by `unique_ptr`s\n- `make_observer` returns a weak_ptr that expires when the shared object dies",
        code="""
#include <cstddef>
#include <memory>

struct Node {
    int value;
    std::unique_ptr<Node> next;
    explicit Node(int v) : value{v} {}
};

struct List {
    std::unique_ptr<Node> head;

    void push_front(int value) {
        //>> (void)value;  // TODO: make_unique + move
        auto node = std::make_unique<Node>(value);
        node->next = std::move(head);
        head = std::move(node);
        //<<
    }

    [[nodiscard]] std::size_t length() const {
        //>> return 0;
        std::size_t count = 0;
        for (const Node* n = head.get(); n != nullptr; n = n->next.get()) {
            ++count;
        }
        return count;
        //<<
    }
};

std::weak_ptr<int> make_observer(const std::shared_ptr<int>& shared) {
    //>> (void)shared;
    //>> return {};
    return shared;
    //<<
}
""",
        test="""
int main() {
    List list;
    for (int i = 0; i < 5; ++i) list.push_front(i);
    CHECK(list.length() == 5, std::format("length = {}", list.length()));
    CHECK(list.head && list.head->value == 4, "push_front puts the newest first");
    auto shared = std::make_shared<int>(7);
    auto copy = shared;
    CHECK(shared.use_count() == 2, "two owners");
    auto watcher = make_observer(shared);
    CHECK(!watcher.expired() && *watcher.lock() == 7, "weak_ptr can lock() while owners exist");
    shared.reset();
    copy.reset();
    CHECK(watcher.expired(), "once the last owner is gone, the weak_ptr expires");
    return koan_finish();
}
""",
    ),
    koan(
        slug="lambdas",
        title="Lambdas and captures",
        difficulty=2,
        xp=20,
        concepts=["lambda", "capture by value/reference", "mutable", "generic lambda", "std::function"],
        hints=[
            'New syntax table: capture lists `[&x]`, `[=]`, init-capture `[n = 0]`, `mutable`, and `auto` parameters.',
            "make_counter needs state that survives between calls: an init-capture plus `mutable`. sum_with must change the caller's `total`: capture it by reference. add: `auto` parameters. compose: return a lambda that captures `f` and `g` by copy.",
            'On other data: `[last = 0](int x) mutable { int d = x - last; last = x; return d; }` remembers `last` between calls · `[&hits](int x) { if (x > 0) ++hits; }` updates a variable outside.',
            'Near-answer: `return [count = 0]() mutable { return ++count; };` · `std::ranges::for_each(values, [&total](int v) { total += v; });` · `return [=](auto x) { return f(g(x)); };`',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `[](int x) { return x * 3; }` | lambda: `[captures](params) { body }` | `auto triple = [](int x) { return x * 3; };` |
| `[&x]` | capture `x` by reference: writes change the original | `[&hits](int x) { if (x > 0) ++hits; }` |
| `[x]`, `[=]` | capture `x` / everything used, by copy | `[=] { return a + b; }` |
| `[n = 0]` | init-capture: a new variable living inside the lambda | `[seen = 0] { ... }` |
| `mutable` | lets the lambda change its by-copy captures between calls | see below |
| `[](auto x)` | generic lambda: works for any type that supports the body | `[](auto x) { return x * x; }` on `3` and `1.5` |
| `std::function<R(Args)>` | holds any callable with that signature | `std::function<bool(int)> pos = [](int x) { return x > 0; };` |
| `std::ranges::for_each(r, f)` | call `f` on every element | `std::ranges::for_each(v, [](int x) { ... });` |
| `auto f(auto a)` | `auto` parameters on a normal function make it a template | `auto twice(auto x) { return x + x; }` |
| `inline auto name = ...;` | a global variable (here holding a lambda) | |

```cpp
auto delta = [last = 0](int x) mutable {   // remembers the previous input
    int d = x - last;
    last = x;
    return d;
};
delta(5);   // 5
delta(8);   // 3
```
""",
        why="Lambdas are inline function objects. Captures decide what they remember and whether they copy or borrow it: the source of both elegant code and dangling-reference bugs.",
        task="- `make_counter` returns a lambda counting 1, 2, 3...\n- `sum_with` adds every element into `total` via a by-reference capture inside `std::ranges::for_each`\n- `add` is a generic lambda\n- `compose(f, g)` returns x ↦ f(g(x))",
        code="""
#include <algorithm>
#include <functional>
#include <vector>

std::function<int()> make_counter() {
    //>> return [] { return 0; };  // TODO: remember a count between calls
    return [count = 0]() mutable { return ++count; };
    //<<
}

void sum_with(const std::vector<int>& values, int& total) {
    //>> (void)values; (void)total;  // TODO: std::ranges::for_each + capture total by reference
    std::ranges::for_each(values, [&total](int v) { total += v; });
    //<<
}

//>> inline auto add = [](int a, int b) { return a + b; };  // TODO: make it generic (works for doubles and strings)
inline auto add = [](auto a, auto b) { return a + b; };
//<<

auto compose(auto f, auto g) {
    //>> return f;
    return [=](auto x) { return f(g(x)); };
    //<<
}
""",
        test="""
#include <string>

int main() {
    auto next = make_counter();
    next();
    next();
    CHECK(next() == 3, "third call returns 3");
    int total = 10;
    sum_with({1, 2, 3}, total);
    CHECK(total == 16, std::format("total = {}", total));
    CHECK(add(1.5, 2.0) == 3.5 && add(std::string{"ab"}, std::string{"c"}) == "abc", "add is generic");
    auto inc_then_double = compose([](int x) { return x * 2; }, [](int x) { return x + 1; });
    CHECK(inc_then_double(4) == 10, std::format("got {}", inc_then_double(4)));
    return koan_finish();
}
""",
    ),
    koan(
        slug="containers-algorithms",
        title="Containers and algorithms",
        difficulty=2,
        xp=25,
        concepts=["unordered_map", "std::ranges::sort", "projections", "std::erase_if", "fold_left"],
        hints=[
            'New syntax table: `m[key]` on an unordered_map, `std::ranges::sort` with a comparator, `std::erase_if`, `std::ranges::fold_left`.',
            'word_freq: `operator[]` inserts 0 for a new key, so incrementing counts. top_k: copy the map into a vector of pairs, sort by count descending then word ascending, take the first k words. drop_negatives: one erase_if. product: fold_left starting from 1.',
            'Two-key sort on other data: `std::ranges::sort(people, [](const auto& a, const auto& b) { return a.age != b.age ? a.age > b.age : a.name < b.name; });` · `std::ranges::fold_left(v, 0, std::plus{})` sums.',
            'Near-answer: `std::vector<std::pair<std::string, int>> entries(freq.begin(), freq.end());` then sort on `.second`/`.first` as above · `std::erase_if(values, [](int x) { return x < 0; });` · `std::ranges::fold_left(values, 1L, std::multiplies{})`.',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `std::unordered_map<K, V>` | hash map (like a Python dict, no order) | `std::unordered_map<std::string, int> bank;` |
| `m[key]` | reference to the value; **inserts** `V{}` (0 for `int`) if missing | `bank["bob"] += 5;` |
| `std::vector<T> v(first, last)` | build a vector from an iterator range | `std::vector<std::pair<std::string, int>> v(m.begin(), m.end());` |
| `std::ranges::sort(v, cmp)` | sort; `cmp(a, b)` returns true if `a` goes first | `std::ranges::sort(ws, std::greater{});  // descending` |
| `std::ranges::sort(v, {}, proj)` | projection: compare by a member/function | `std::ranges::sort(ws, {}, &std::string::size);` |
| `std::erase_if(c, pred)` | remove every matching element (C++20) | `std::erase_if(s, [](char c) { return c == ' '; });` |
| `std::ranges::fold_left(r, init, op)` | C++23 fold/reduce | `std::ranges::fold_left(v, 0, std::plus{})` → sum |
| `std::plus{}`, `std::multiplies{}`, `std::greater{}` | operators as function objects | |
| `1L` | a `long` literal (so the fold accumulates in `long`) | `0L` |
""",
        why="The standard library's containers and algorithms (with C++20 ranges and projections) replace most hand-written loops with intent-revealing one-liners.",
        task="- `word_freq` counts words\n- `top_k` returns the k most frequent (ties: alphabetical)\n- `drop_negatives` removes negatives in place\n- `product` multiplies with `std::ranges::fold_left`",
        code="""
#include <algorithm>
#include <functional>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

std::unordered_map<std::string, int> word_freq(const std::vector<std::string>& words) {
    //>> (void)words;
    //>> return {};
    std::unordered_map<std::string, int> freq;
    for (const auto& word : words) {
        ++freq[word];
    }
    return freq;
    //<<
}

std::vector<std::string> top_k(const std::unordered_map<std::string, int>& freq, std::size_t k) {
    //>> (void)freq; (void)k;
    //>> return {};
    std::vector<std::pair<std::string, int>> entries(freq.begin(), freq.end());
    std::ranges::sort(entries, [](const auto& a, const auto& b) {
        return a.second != b.second ? a.second > b.second : a.first < b.first;
    });
    std::vector<std::string> out;
    for (const auto& [word, count] : entries) {
        if (out.size() == k) break;
        out.push_back(word);
    }
    return out;
    //<<
}

void drop_negatives(std::vector<int>& values) {
    //>> (void)values;  // TODO: std::erase_if
    std::erase_if(values, [](int x) { return x < 0; });
    //<<
}

long product(const std::vector<int>& values) {
    //>> (void)values;
    //>> return 0;
    return std::ranges::fold_left(values, 1L, std::multiplies{});
    //<<
}
""",
        test="""
int main() {
    auto freq = word_freq({"rg", "sed", "rg", "awk", "sed", "rg"});
    CHECK(freq["rg"] == 3 && freq["awk"] == 1, "counts");
    auto top = top_k(freq, 2);
    CHECK((top == std::vector<std::string>{"rg", "sed"}), "top 2 = rg, sed");
    auto tied = top_k(word_freq({"b", "a", "c"}), 2);
    CHECK((tied == std::vector<std::string>{"a", "b"}), "ties break alphabetically");
    std::vector<int> v{3, -1, 4, -1, 5};
    drop_negatives(v);
    CHECK((v == std::vector<int>{3, 4, 5}), "negatives removed");
    CHECK(product({2, 3, 7}) == 42 && product({}) == 1, "fold_left product");
    return koan_finish();
}
""",
    ),
    koan(
        slug="ranges-views",
        title="Ranges and views",
        difficulty=3,
        xp=30,
        concepts=["std::views::filter", "transform", "iota", "take", "zip", "std::ranges::to"],
        hints=[
            'New syntax table: `std::views::filter`, `transform`, `iota`, `take`, `zip`, and `std::ranges::to<std::vector>()`.',
            'Build each answer as a left-to-right pipeline and materialise it with `ranges::to`. first_primes starts from an infinite `iota(2)`, keeps primes and stops with `take(n)`. dot: zip the two vectors and add up x*y in a range-for.',
            'On other data: `std::views::iota(1, 6) | std::views::transform([](int x) { return x * 10; }) | std::ranges::to<std::vector>()` → {10,20,30,40,50} · `for (auto [name, score] : std::views::zip(names, scores))`.',
            'Near-answer: `values | std::views::filter(/*even*/) | std::views::transform(/*square*/) | std::ranges::to<std::vector>()` · `std::views::iota(2) | std::views::filter(is_prime) | std::views::take(n) | std::ranges::to<std::vector>()`.',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `r \| adaptor` | pipe a range into a view adaptor; read left to right, like a shell pipe | `words \| std::views::take(2)` |
| `std::views::filter(pred)` | keep elements where `pred` is true (lazy) | `std::views::filter([](int x) { return x > 0; })` |
| `std::views::transform(f)` | apply `f` to every element (lazy) | `std::views::transform([](int x) { return x * 10; })` |
| `std::ranges::to<std::vector>()` | C++23: run the pipeline and collect into a container | see below |
| `std::views::iota(a)` / `iota(a, b)` | a, a+1, a+2, … forever / up to b (exclusive) | `std::views::iota(1, 4)` → 1 2 3 |
| `std::views::take(n)` | first `n` elements; makes an infinite view finite | |
| `std::views::zip(a, b)` | C++23: pairs of elements, stops at the shorter range | `for (auto [n, s] : std::views::zip(names, scores))` |
| `constexpr bool f(...)` | a function that may also run at compile time (koan 12) | |
| `static_cast<long>(x)` | explicit conversion, here to multiply without `int` overflow | |

```cpp
auto odds = std::views::iota(1)                                // 1, 2, 3, ... (infinite)
          | std::views::filter([](int x) { return x % 2; })
          | std::views::take(3)
          | std::ranges::to<std::vector>();                    // {1, 3, 5}
```
""",
        why="Views are lazy, composable pipelines: shell pipes for data. Nothing is computed until you iterate, so even infinite sequences work.",
        task="- `evens_squared` via filter | transform | to<vector>\n- `first_primes(n)` from an infinite `iota`\n- `dot` (dot product) using `views::zip`",
        code="""
#include <ranges>
#include <vector>

constexpr bool is_prime(int n) {
    if (n < 2) return false;
    for (int d = 2; d * d <= n; ++d) {
        if (n % d == 0) return false;
    }
    return true;
}

std::vector<int> evens_squared(const std::vector<int>& values) {
    //>> (void)values;
    //>> return {};
    return values | std::views::filter([](int x) { return x % 2 == 0; }) |
           std::views::transform([](int x) { return x * x; }) | std::ranges::to<std::vector>();
    //<<
}

std::vector<int> first_primes(int n) {
    //>> (void)n;
    //>> return {};
    return std::views::iota(2) | std::views::filter(is_prime) | std::views::take(n) | std::ranges::to<std::vector>();
    //<<
}

long dot(const std::vector<int>& a, const std::vector<int>& b) {
    //>> (void)a; (void)b;
    //>> return 0;
    long sum = 0;
    for (const auto [x, y] : std::views::zip(a, b)) {
        sum += static_cast<long>(x) * y;
    }
    return sum;
    //<<
}
""",
        test="""
int main() {
    CHECK((evens_squared({1, 2, 3, 4, 5, 6}) == std::vector<int>{4, 16, 36}), "evens squared");
    CHECK((first_primes(6) == std::vector<int>{2, 3, 5, 7, 11, 13}), "first 6 primes");
    CHECK(dot({1, 2, 3}, {4, 5, 6}) == 32, std::format("dot = {}", dot({1, 2, 3}, {4, 5, 6})));
    CHECK(dot({1, 2, 3}, {10}) == 10, "zip stops at the shorter range");
    return koan_finish();
}
""",
    ),
    koan(
        slug="format",
        title="std::format and custom formatters",
        difficulty=3,
        xp=25,
        concepts=["format spec", "hex/binary", "fill & align", "std::formatter specialization"],
        hints=[
            'New syntax table: the format-spec mini-language `{:[fill][align][width][.prec][type]}` (same as Python f-strings) and the `std::formatter<T>` pattern.',
            'hex_and_binary: two `{}` fields for the same value, one hex with `#` (adds 0x), one binary zero-padded to width 8. banner: fill `*`, centre `^`, width 9. Point: specialise `std::formatter<Point>`, build "(x, y)" with std::format and pass it to the base string formatter.',
            'On other data: `std::format("{:#o} {:04b}", 8, 5)` → `010 0101` · `std::format("{:-<7}", "ab")` → `ab-----` · the `Temp` formatter in the README.',
            'Near-answer: `std::format("{:#x} {:08b}", value, value)` · `std::format("{:*^9}", text)` · the Temp formatter with `"({}, {})", p.x, p.y` · describe: `std::format("point {}", p)`.',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `{:x}` / `{:#x}` | hex / hex with `0x` prefix (`o` octal, `b` binary) | `std::format("{:#x}", 31)` → `"0x1f"` |
| `{:04b}` | `0` = pad with zeros, `4` = width | `std::format("{:04b}", 5)` → `"0101"` |
| `{:-<7}` | fill char, then alignment `<` `>` `^`, then width | `std::format("{:-<7}", "ab")` → `"ab-----"` |
| `{:+.2f}` | sign, precision, fixed-point | `std::format("{:+.2f}", 3.14159)` → `"+3.14"` |
| `template <> struct std::formatter<T>` | explicit specialisation: teach a std template about your type | see below |
| `: std::formatter<std::string>` | inherit string formatting, so width/align specs work for free | `std::format("[{:>8}]", Temp{1.5})` → `"[    1.5C]"` |

```cpp
struct Temp { double c; };

template <>
struct std::formatter<Temp> : std::formatter<std::string> {
    auto format(const Temp& t, std::format_context& ctx) const {
        return std::formatter<std::string>::format(std::format("{}C", t.c), ctx);
    }
};
// std::format("{}", Temp{21.5}) == "21.5C"
```
""",
        why="std::format (and std::print) is type-safe printf: no format-string crashes, works with your own types, and the same mini-language as Python's f-strings.",
        task="- `hex_and_binary(255)` → `0xff 11111111`\n- `banner(\"ok\")` → `***ok****` (centred in 9 with *)\n- make `Point` formattable as `(x, y)`",
        code="""
#include <format>
#include <string>

struct Point {
    int x;
    int y;
};

//>> // TODO: specialize std::formatter<Point>
template <>
struct std::formatter<Point> : std::formatter<std::string> {
    auto format(const Point& p, std::format_context& ctx) const {
        return std::formatter<std::string>::format(std::format("({}, {})", p.x, p.y), ctx);
    }
};
//<<

std::string hex_and_binary(int value) {
    //>> return std::to_string(value);
    return std::format("{:#x} {:08b}", value, value);
    //<<
}

std::string banner(const std::string& text) {
    //>> return text;
    return std::format("{:*^9}", text);
    //<<
}

std::string describe(const Point& p) {
    //>> (void)p;
    //>> return "?";
    return std::format("point {}", p);
    //<<
}
""",
        test="""
int main() {
    CHECK(hex_and_binary(255) == "0xff 11111111", std::format("got '{}'", hex_and_binary(255)));
    CHECK(banner("ok") == "***ok****", std::format("got '{}'", banner("ok")));
    CHECK(describe({3, -4}) == "point (3, -4)", std::format("got '{}'", describe({3, -4})));
    return koan_finish();
}
""",
    ),
    koan(
        slug="optional-variant-expected",
        title="optional, variant, expected",
        difficulty=3,
        xp=30,
        concepts=["std::optional", "std::variant", "std::visit", "overloaded pattern", "std::expected", "and_then/transform"],
        hints=[
            'New syntax table: `std::optional`/`std::nullopt`, `std::from_chars`, `std::variant` + `std::visit` + `overloaded`, `std::expected`/`std::unexpected`.',
            'parse_int: from_chars succeeds only if `ec == std::errc{}` AND it consumed the whole text (`ptr == end`); empty text fails too. kind_of: std::visit with an overloaded set of three lambdas. safe_div: return std::unexpected when b == 0. half_of_parsed: parse, turn a missing value into an error, then hand over to safe_div.',
            'On other data: `auto [p, ec] = std::from_chars(s.data(), s.data() + s.size(), n);` · the `show` visitor in the README · `if (x < 0) return std::unexpected{"negative"};`.',
            'Near-answer: `if (b == 0) return std::unexpected{"divide by zero"}; return a / b;` · `auto p = parse_int(text); if (!p) return std::unexpected{"not a number"}; return safe_div(*p, 2);`',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `std::optional<T>`, `std::nullopt` | a `T` or nothing | `std::optional<int> none = std::nullopt;` |
| `if (!opt)`, `*opt`, `opt.value_or(d)` | test, unwrap, unwrap with default | `none.value_or(7)` → `7` |
| `std::string_view` | read-only view of characters (more in koan 09) | `std::string_view s = "123";` |
| `std::from_chars(first, last, out)` | parse a number without exceptions; returns `{ptr, ec}` | `auto [p, ec] = std::from_chars(s.data(), s.data() + s.size(), n);` |
| `std::errc{}` | the "no error" value of `ec` | `ec == std::errc{}` |
| `std::variant<A, B>` | holds exactly one of the listed types | `std::variant<int, std::string> id = 7;` |
| `std::visit(visitor, v)` | calls the visitor overload matching the type held | see below |
| `template <class... Fs>`, `Fs...` | variadic template: a pack of types (the `overloaded` helper) | |
| `using Alias = Type;` | type alias | `using Id = std::variant<int, std::string>;` |
| `std::expected<T, E>` | C++23: a `T` or an error `E` | see below |
| `std::unexpected{e}` | build the error side | `return std::unexpected{"negative"};` |
| `.error()`, `.transform(f)`, `.and_then(f)` | read the error / map the value / chain a step that returns `expected` | |

```cpp
using Id = std::variant<int, std::string>;
std::string show(const Id& id) {
    return std::visit(overloaded{
        [](int n) { return "#" + std::to_string(n); },
        [](const std::string& name) { return name; },
    }, id);
}                                                     // show(7) == "#7"

std::expected<double, std::string> checked_sqrt(double x) {
    if (x < 0) return std::unexpected{"negative"};
    return std::sqrt(x);
}
auto r = checked_sqrt(16).transform([](double v) { return v + 1; });   // r == 5.0
```
""",
        why="These vocabulary types make 'maybe', 'one of several' and 'value or error' explicit in the type, instead of sentinel values, nullptrs or exceptions.",
        task="- `parse_int` → `std::optional<int>`\n- `kind_of` visits a variant\n- `safe_div` → `std::expected<int, std::string>` and `half_of_parsed` chains with `and_then`",
        code="""
#include <charconv>
#include <expected>
#include <optional>
#include <string>
#include <string_view>
#include <variant>

std::optional<int> parse_int(std::string_view text) {
    //>> (void)text;
    //>> return 0;
    int value = 0;
    const auto [ptr, ec] = std::from_chars(text.data(), text.data() + text.size(), value);
    if (ec != std::errc{} || ptr != text.data() + text.size() || text.empty()) {
        return std::nullopt;
    }
    return value;
    //<<
}

template <class... Fs>
struct overloaded : Fs... {
    using Fs::operator()...;
};

using Value = std::variant<int, double, std::string>;

std::string kind_of(const Value& v) {
    //>> (void)v;
    //>> return "?";
    return std::visit(overloaded{
                          [](int i) { return "int " + std::to_string(i); },
                          [](double) { return std::string{"double"}; },
                          [](const std::string& s) { return "string of " + std::to_string(s.size()); },
                      },
                      v);
    //<<
}

std::expected<int, std::string> safe_div(int a, int b) {
    //>> return a / b;  // TODO: b == 0 must be an error, not a crash
    if (b == 0) {
        return std::unexpected{"divide by zero"};
    }
    return a / b;
    //<<
}

std::expected<int, std::string> half_of_parsed(std::string_view text) {
    //>> (void)text;
    //>> return std::unexpected{"TODO"};
    auto parsed = parse_int(text);
    if (!parsed) {
        return std::unexpected{"not a number"};
    }
    return safe_div(*parsed, 2).transform([](int half) { return half; });
    //<<
}
""",
        test="""
int main() {
    CHECK(parse_int("42") == 42 && !parse_int("4x2") && !parse_int(""), "parse_int");
    CHECK(kind_of(Value{7}) == "int 7" && kind_of(Value{2.5}) == "double", "visit int/double");
    CHECK(kind_of(Value{std::string{"vim"}}) == "string of 3", "visit string");
    CHECK(safe_div(9, 3) == 3, "9 / 3");
    auto bad = safe_div(1, 0);
    CHECK(!bad && bad.error() == "divide by zero", "division by zero is an error value");
    CHECK(half_of_parsed("10") == 5, "chain parse -> divide");
    CHECK(!half_of_parsed("ten") && half_of_parsed("ten").error() == "not a number", "parse failure propagates");
    return koan_finish();
}
""",
    ),
    koan(
        slug="string-view-span",
        title="string_view and span",
        difficulty=2,
        xp=20,
        concepts=["std::string_view", "std::span", "non-owning views", "subspan"],
        hints=[
            "New syntax table: string_view's `find_first_not_of` / `find_last_not_of` / `substr` / `remove_prefix` / `npos`, and `span::subspan`.",
            'trim: find the first and last non-whitespace positions; none → empty view; otherwise substr between them. split: loop { find sep; keep the piece before it; remove_prefix past it }, and when find returns npos keep the last piece and stop. sum_middle: fewer than 3 elements → 0, else subspan(1, size - 2) and add.',
            'On other data: `std::string_view path = "/usr/bin"; path.substr(path.find_last_of(\'/\') + 1)` → `bin` · `std::string_view kv = "key=value"; kv.remove_prefix(4);` → `value` · `std::span<const int> s = arr; s.subspan(2)` drops two.',
            'Near-answer (trim): `auto first = text.find_first_not_of(ws); if (first == std::string_view::npos) return {}; auto last = text.find_last_not_of(ws); return text.substr(first, last - first + 1);`',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sv.substr(pos, n)` | a smaller view of the same characters (no copy) | `std::string_view{"/usr/bin"}.substr(5)` → `"bin"` |
| `find_first_not_of(set)` / `find_last_not_of(set)` | index of the first / last char **not** in `set` | `std::string_view{"--x--"}.find_first_not_of('-')` → `2` |
| `std::string_view::npos` | "not found" (returned by every `find*`) | `std::string_view{"abc"}.find('z') == npos` |
| `sv.remove_prefix(n)` | shrink the view from the front | `kv.remove_prefix(4);  // "key=value" → "value"` |
| `constexpr std::string_view ws = " \t";` | a compile-time constant view | |
| `std::span<const T>` | view of any contiguous array: `std::array`, `std::vector`, C array | `std::span<const int> s = arr;` |
| `s.subspan(offset, count)` | a window into the span (count optional) | `s.subspan(1, 2)` |
| `std::array<T, N>` | fixed-size array with value semantics (test.cpp) | `std::array<int, 4> arr{1, 2, 3, 4};` |
| `std::accumulate(b, e, init)` | classic sum over an iterator range | `std::accumulate(arr.begin(), arr.end(), 0)` → `10` |

A view never owns its data: returning a `string_view` into a local `std::string` is a dangling pointer (ASan will tell you).
""",
        why="string_view and span are cheap, non-owning windows onto someone else's data. They make APIs accept any contiguous string/array without copies.",
        task="- `trim` whitespace off both ends (no copies)\n- `split` on a separator into views\n- `sum_middle` sums all but the first and last element via `subspan`",
        code="""
#include <numeric>
#include <span>
#include <string_view>
#include <vector>

std::string_view trim(std::string_view text) {
    //>> return text;
    constexpr std::string_view ws = " \\t\\n";
    const auto first = text.find_first_not_of(ws);
    if (first == std::string_view::npos) {
        return {};
    }
    const auto last = text.find_last_not_of(ws);
    return text.substr(first, last - first + 1);
    //<<
}

std::vector<std::string_view> split(std::string_view text, char sep) {
    //>> (void)text; (void)sep;
    //>> return {};
    std::vector<std::string_view> parts;
    while (true) {
        const auto pos = text.find(sep);
        parts.push_back(text.substr(0, pos));
        if (pos == std::string_view::npos) {
            return parts;
        }
        text.remove_prefix(pos + 1);
    }
    //<<
}

long sum_middle(std::span<const int> values) {
    //>> (void)values;
    //>> return 0;
    if (values.size() < 3) {
        return 0;
    }
    const auto middle = values.subspan(1, values.size() - 2);
    return std::accumulate(middle.begin(), middle.end(), 0L);
    //<<
}
""",
        test="""
#include <array>
int main() {
    CHECK(trim("  \\tgrep -n \\n") == "grep -n", std::format("got '{}'", trim("  \\tgrep -n \\n")));
    CHECK(trim("   ").empty(), "all whitespace -> empty");
    auto parts = split("a:b::c", ':');
    CHECK((parts == std::vector<std::string_view>{"a", "b", "", "c"}), "split keeps empty fields");
    std::array<int, 5> arr{100, 1, 2, 3, 100};
    std::vector<int> vec{5, 6, 7};
    CHECK(sum_middle(arr) == 6 && sum_middle(vec) == 6, "span accepts arrays and vectors");
    return koan_finish();
}
""",
    ),
    koan(
        slug="enum-class",
        title="enum class, to_underlying, using enum",
        difficulty=2,
        xp=15,
        concepts=["enum class", "underlying type", "std::to_underlying", "using enum"],
        hints=[
            "New syntax table: `enum class ... : std::uint8_t`, `std::to_underlying`, `using enum`. The static_assert messages in test.cpp say what's wrong with the starter's enum.",
            'Make Level scoped with a 1-byte underlying type. severity converts to that integer. label: a switch with `using enum Level;` inside, so cases can say `Debug` instead of `Level::Debug`.',
            'On other data: `enum class Dir : std::uint8_t { N, E, S, W };` · `std::to_underlying(Dir::S) == 2` · `switch (d) { using enum Dir; case N: return "^"; ... }`.',
            'Near-answer: `enum class Level : std::uint8_t { Debug, Info, Warn, Error };` and `return std::to_underlying(level);`',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `enum class E : std::uint8_t { A, B };` | scoped enum with a 1-byte underlying type | `enum class Dir : std::uint8_t { N, E, S, W };` |
| `E::A` | enumerators must be qualified; no implicit conversion to `int` | `Dir d = Dir::S;` |
| `std::to_underlying(e)` | C++23: the integer value, explicitly | `std::to_underlying(Dir::S)` → `2` |
| `using enum E;` | C++20: bring the enumerators into scope (e.g. inside a `switch`) | see below |
| `std::is_convertible_v<A, B>`, `sizeof(T)` | type trait / size in bytes (test.cpp's static_asserts) | `sizeof(Dir)` → `1` |

```cpp
const char* arrow(Dir d) {
    switch (d) {
        using enum Dir;            // now N means Dir::N
    case N: return "^";
    case E: return ">";
    case S: return "v";
    case W: return "<";
    }
    return "?";
}
```
""",
        why="Scoped enums don't leak names or silently convert to int, so the compiler catches mixed-up flags. `using enum` keeps switches readable.",
        task="- `Level` is a 1-byte `enum class` (Debug, Info, Warn, Error)\n- `severity` returns the underlying number\n- `label` returns \"DBG\"/\"INF\"/\"WRN\"/\"ERR\" using `using enum`",
        code="""
#include <cstdint>
#include <string_view>
#include <utility>

//>> enum Level { Debug, Info, Warn, Error };  // TODO: scoped, 1 byte
enum class Level : std::uint8_t { Debug, Info, Warn, Error };
//<<

int severity(Level level) {
    //>> (void)level;
    //>> return -1;
    return std::to_underlying(level);
    //<<
}

std::string_view label(Level level) {
    //>> (void)level;
    //>> return "?";
    switch (level) {
        using enum Level;
    case Debug: return "DBG";
    case Info: return "INF";
    case Warn: return "WRN";
    case Error: return "ERR";
    }
    return "?";
    //<<
}
""",
        test="""
#include <type_traits>
static_assert(!std::is_convertible_v<Level, int>, "make Level an enum class (no implicit int conversion)");
static_assert(sizeof(Level) == 1, "give Level a std::uint8_t underlying type");

int main() {
    CHECK(severity(Level::Warn) == 2, "severity(Warn) == 2");
    CHECK(label(Level::Error) == "ERR" && label(Level::Debug) == "DBG", "labels");
    return koan_finish();
}
""",
    ),
    koan(
        slug="concepts",
        title="Templates and concepts",
        difficulty=4,
        xp=35,
        concepts=["concepts", "requires-expressions", "constrained templates", "fold expressions"],
        hints=[
            'New syntax table: `concept`, requires-expressions, `{ expr } -> std::convertible_to<T>`, fold expressions. The static_asserts in test.cpp list exactly what each concept must accept and reject.',
            'Shape: require that `s.area()` compiles on a `const T&` and converts to double. Number: integral OR floating point (both are standard concepts). total_area: fold `+` over the pack, starting from 0.0. clamp_to: low if below, high if above, else value.',
            'On other data: `template <class T> concept Named = requires(const T& t) { { t.name() } -> std::convertible_to<std::string>; };` · `(0 + ... + xs)` adds up a pack.',
            'Near-answer: `concept Shape = requires(const T& shape) { { shape.area() } -> std::convertible_to<double>; };` · `concept Number = std::integral<T> || std::floating_point<T>;` · `return (0.0 + ... + shapes.area());`',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `template <class T> concept C = expr;` | a named compile-time yes/no question about a type | `template <class T> concept Small = sizeof(T) <= 4;` |
| `requires(const T& t) { ... }` | true if every expression inside compiles for `T` | see below |
| `{ t.f() } -> std::convertible_to<X>;` | ...and its result converts to `X` | |
| `std::integral<T>`, `std::floating_point<T>` | standard concepts; combine with `&&` / `\|\|` | `std::integral<char>` → true |
| `template <C T>` | constrained template: only types satisfying `C` | `template <std::integral T> T twice(T x);` |
| `template <C... Ts>`, `const Ts&... xs` | a pack of constrained types / a pack of parameters | |
| `(init + ... + expr)` | fold expression: expand the pack with an operator | `(0 + ... + xs)` |

```cpp
template <class T>
concept Named = requires(const T& t) {
    { t.name() } -> std::convertible_to<std::string>;
};
struct Cat { std::string name() const { return "tom"; } };
static_assert(Named<Cat> && !Named<int>);

template <class... Ts>
auto sum_all(Ts... xs) { return (0 + ... + xs); }   // sum_all(1, 2, 3) == 6
```
""",
        why="Concepts name the requirements a template needs, so misuse gives a one-line error instead of 200 lines of template spew, and your LSP can tell you what fits.",
        task="- define concept `Shape` (has `area()` convertible to double)\n- `total_area(shapes...)` sums any number of shapes with a fold expression\n- `Number` concept (integral or floating point) and `clamp_to`",
        code="""
#include <concepts>

//>> template <class T> concept Shape = true;  // TODO: require a const area() returning something convertible to double
template <class T>
concept Shape = requires(const T& shape) {
    { shape.area() } -> std::convertible_to<double>;
};
//<<

//>> template <class T> concept Number = true;  // TODO: integral or floating point
template <class T>
concept Number = std::integral<T> || std::floating_point<T>;
//<<

template <Shape... Ts>
double total_area(const Ts&... shapes) {
    //>> return 0;  // TODO: fold expression
    return (0.0 + ... + shapes.area());
    //<<
}

template <Number T>
T clamp_to(T value, T low, T high) {
    //>> (void)low; (void)high;
    //>> return value;
    return value < low ? low : (high < value ? high : value);
    //<<
}

struct Square {
    double side;
    [[nodiscard]] double area() const { return side * side; }
};

struct Circle {
    double r;
    [[nodiscard]] double area() const { return 3.0 * r * r; }  // engineer's pi
};
""",
        test="""
#include <string>
static_assert(Shape<Square> && Shape<Circle>, "Square and Circle are Shapes");
static_assert(!Shape<int> && !Shape<std::string>, "int and string are not Shapes: constrain the concept");
static_assert(Number<int> && Number<double> && !Number<std::string>, "Number = integral or floating point");

int main() {
    CHECK(total_area(Square{2}, Circle{1}, Square{1}) == 8.0, std::format("total = {}", total_area(Square{2}, Circle{1}, Square{1})));
    CHECK(clamp_to(15, 0, 10) == 10 && clamp_to(-2.5, -1.0, 1.0) == -1.0, "clamp_to");
    return koan_finish();
}
""",
    ),
    koan(
        slug="constexpr",
        title="constexpr and consteval: compile-time computation",
        difficulty=3,
        xp=30,
        concepts=["constexpr functions", "consteval", "static_assert", "compile-time tables", "if consteval"],
        hints=[
            "New syntax table: `constexpr` vs `consteval`. test.cpp's static_asserts fail until the functions can run at compile time.",
            'Put `constexpr` in front of factorial and `consteval` in front of square. Fill the table with an ordinary for loop: constexpr functions may contain loops and assignments.',
            'On other data: `constexpr int cube(int x) { return x * x * x; }  static_assert(cube(3) == 27);` · `consteval int kib(int n) { return n * 1024; }`',
            'Near-answer: `constexpr long factorial(int n) {` · `consteval int square(int x) { return x * x; }` · `for (int i = 0; i < 10; ++i) table[i] = i * i;`',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `constexpr` function | may run at compile time when its arguments are constants; also callable at runtime | `constexpr int cube(int x) { return x * x * x; }` |
| `consteval` function | **must** run at compile time (an "immediate function") | `consteval int kib(int n) { return n * 1024; }` |
| `constexpr auto x = f();` | a variable computed by the compiler | `constexpr auto pow2 = powers();` |
| `static_assert(f(3) == 27);` | proves the value at compile time | `static_assert(cube(3) == 27);` |

```cpp
constexpr std::array<int, 5> powers() {   // loops and assignments are fine in constexpr
    std::array<int, 5> t{};
    for (int i = 0; i < 5; ++i) t[i] = 1 << i;
    return t;
}
constexpr auto pow2 = powers();           // {1, 2, 4, 8, 16}, built by the compiler
static_assert(pow2[4] == 16);
```
""",
        why="Work done at compile time costs nothing at runtime and is checked by the compiler. In hardware-adjacent code, lookup tables and bit masks are often built this way.",
        task="- `factorial` is constexpr\n- `square` is consteval\n- `squares` is a constexpr std::array table of i² for i in 0..9\n- the test file static_asserts all of it",
        code="""
#include <array>

//>> long factorial(int n) {  // TODO: constexpr
constexpr long factorial(int n) {
//<<
    return n <= 1 ? 1 : n * factorial(n - 1);
}

//>> int square(int x) { return x * x; }  // TODO: consteval
consteval int square(int x) { return x * x; }
//<<

constexpr std::array<int, 10> make_squares() {
    std::array<int, 10> table{};
    //>> // TODO: fill table[i] = i * i
    for (int i = 0; i < 10; ++i) {
        table[i] = i * i;
    }
    //<<
    return table;
}

constexpr auto squares = make_squares();
""",
        test="""
static_assert(factorial(10) == 3628800, "factorial must be constexpr and correct");
static_assert(square(12) == 144, "square must be usable at compile time");
static_assert(squares[9] == 81 && squares[3] == 9, "the table is built at compile time");

int main() {
    CHECK(factorial(5) == 120, "runtime call works too");
    return koan_finish();
}
""",
    ),
    koan(
        slug="spaceship",
        title="The spaceship operator <=>",
        difficulty=3,
        xp=25,
        concepts=["operator<=>", "defaulted comparisons", "std::weak_ordering", "custom ordering"],
        hints=[
            'New syntax table: defaulted `operator<=>`, `std::weak_ordering`, and why a custom `<=>` needs its own `operator==`.',
            'Version: one defaulted `<=>` compares members in declaration order (major, minor, patch). CiString: compare lowered copies with `<=>` (std::string gives strong_ordering, which converts to weak_ordering) and write `==` the same way.',
            'On other data: `std::weak_ordering operator<=>(const Mag& o) const { return std::abs(v) <=> std::abs(o.v); }` plus `bool operator==(const Mag& o) const { return std::abs(v) == std::abs(o.v); }`',
            'Near-answer: `auto operator<=>(const Version&) const = default;` · `return lower(text) <=> lower(other.text);` · `return lower(text) == lower(other.text);`',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `a <=> b` | three-way compare: result is `< 0`, `== 0` or `> 0` | `(1 <=> 2) < 0` → true |
| `auto operator<=>(const T&) const = default;` | compiler writes `<` `<=` `>` `>=` (and `==`), comparing members in declaration order | see below |
| `std::strong_ordering` | equal means identical (ints, strings) | |
| `std::weak_ordering` | "equivalent" may still differ (e.g. case-insensitive, by absolute value) | |
| custom `operator==` | a hand-written `<=>` does **not** give you `==`; write it too | |
| `std::ranges::transform(in, out, f)` | write `f(x)` for each element (the starter's `lower`) | |

```cpp
struct Date {
    int y, m, d;
    auto operator<=>(const Date&) const = default;   // Date{2024, 1, 2} < Date{2024, 2, 1}
};

struct Mag {                                          // compares by absolute value
    int v;
    std::weak_ordering operator<=>(const Mag& o) const { return std::abs(v) <=> std::abs(o.v); }
    bool operator==(const Mag& o) const { return std::abs(v) == std::abs(o.v); }
};                                                    // Mag{-3} == Mag{3}
```
""",
        why="One defaulted operator gives you all six comparisons, consistently. Custom orderings (weak/partial) express 'equivalent but not identical' precisely.",
        task="- default `<=>` for `Version` (compare major, minor, patch)\n- `CiString` compares case-insensitively with `std::weak_ordering`",
        code="""
#include <algorithm>
#include <cctype>
#include <compare>
#include <string>

struct Version {
    int major;
    int minor;
    int patch;
    //>> // TODO: default the three-way comparison
    auto operator<=>(const Version&) const = default;
    //<<
};

inline std::string lower(std::string s) {
    std::ranges::transform(s, s.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return s;
}

struct CiString {
    std::string text;
    //>> // TODO: operator<=> returning std::weak_ordering, and operator==, both case-insensitive
    std::weak_ordering operator<=>(const CiString& other) const { return lower(text) <=> lower(other.text); }
    bool operator==(const CiString& other) const { return lower(text) == lower(other.text); }
    //<<
};
""",
        test="""
#include <vector>
int main() {
    std::vector<Version> vs{{1, 10, 0}, {1, 2, 3}, {0, 9, 9}};
    std::ranges::sort(vs);
    CHECK(vs.front() == (Version{0, 9, 9}) && vs.back() == (Version{1, 10, 0}), "sorted versions");
    CHECK((Version{1, 2, 3} < Version{1, 3, 0}), "<");
    CHECK((CiString{"Vim"} == CiString{"vIM"}), "case-insensitive equality");
    CHECK((CiString{"awk"} < CiString{"SED"}), "case-insensitive ordering");
    return koan_finish();
}
""",
    ),
    koan(
        slug="cpp26-preview",
        title="C++26 sneak peek: pack indexing, = delete(\"why\"), mdspan",
        difficulty=4,
        xp=35,
        concepts=["pack indexing (C++26)", "= delete(reason) (C++26)", "_ placeholder (C++26)", "std::mdspan (C++23)"],
        hints=[
            'New syntax table: `pack...[i]`, `sizeof...`, `= delete("why")`, `std::mdspan` with `m[i, j]`, and `_` in structured bindings.',
            'first is index 0 of the pack; last is index `sizeof...(values) - 1`. Declare a `process(double)` overload that is deleted with a message. trace: view the data as an n×n mdspan and add `matrix[i, i]`. sum_firsts: unpack each pair as `[a, _]`.',
            'On other data: `xs...[1]` (second element) · `void send(const char*) = delete("pass a std::string");` · `std::mdspan img(px.data(), 2, 3); img[1, 2]` · `for (const auto& [_, age] : ages)`.',
            'Near-answer: `return values...[sizeof...(values) - 1];` · `int process(double) = delete("...");` · `std::mdspan matrix(data.data(), n, n);` then `sum += matrix[i, i];` in a loop.',
        ],
        syntax=r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `pack...[i]` | C++26 pack indexing: the i-th element of a parameter pack | `template <class... Ts> auto second(Ts... xs) { return xs...[1]; }` |
| `sizeof...(pack)` | how many elements a pack has | `count_args(1, 2, 3)` → `3` |
| `= delete("reason")` | C++26: deleted function with your own error message | `void send(const char*) = delete("pass a std::string");` |
| `std::mdspan m(ptr, rows, cols)` | C++23 multi-dimensional view over flat, row-major data | `std::mdspan img(px.data(), 2, 3);` |
| `m[i, j]` | C++23 multi-dimensional subscript | `img[1, 2]` is `px[1 * 3 + 2]` |
| `auto [a, _] = pair;` | C++26 `_` placeholder: a name you won't use (may repeat) | `for (const auto& [_, age] : ages) total += age;` |
| `concept C = requires(T v) { f(v); };` | test.cpp asks "does this call compile?" (koan 11) | |
""",
        why="C++26 is the newest standard. Pack indexing removes a whole category of template metaprogramming tricks, deleted-with-reason gives readable errors, and mdspan is the standard multi-dimensional array view.",
        task="- `first` / `last` with pack indexing\n- forbid `process(double)` with a reason (the test checks it can't be called)\n- `trace` sums the diagonal of a row-major matrix through `std::mdspan`\n- `sum_firsts` uses the `_` placeholder for the ignored half of each pair",
        code="""
#include <cstddef>
#include <mdspan>
#include <utility>
#include <vector>

template <class... Ts>
constexpr auto first(Ts... values) {
    //>> return 0;  // TODO: pack indexing
    return values...[0];
    //<<
}

template <class... Ts>
constexpr auto last(Ts... values) {
    //>> return 0;
    return values...[sizeof...(values) - 1];
    //<<
}

inline int process(int x) { return x * 2; }
//>> // TODO: delete the double overload, with a reason
int process(double) = delete("process() takes integers; round explicitly");
//<<

int trace(const std::vector<int>& data, std::size_t n) {
    //>> (void)data; (void)n;
    //>> return 0;
    std::mdspan matrix(data.data(), n, n);
    int sum = 0;
    for (std::size_t i = 0; i < n; ++i) {
        sum += matrix[i, i];
    }
    return sum;
    //<<
}

int sum_firsts(const std::vector<std::pair<int, int>>& pairs) {
    //>> (void)pairs;
    //>> return 0;
    int sum = 0;
    for (const auto& [a, _] : pairs) {
        sum += a;
    }
    return sum;
    //<<
}
""",
        test="""
template <class T>
concept CanProcess = requires(T value) { process(value); };
static_assert(CanProcess<int>, "process(int) still works");
static_assert(!CanProcess<double>, "process(double) should be = delete(\\"reason\\")");
static_assert(first(7, 'x', 2.5) == 7 && last(7, 'x', 2.5) == 2.5, "pack indexing");

int main() {
    CHECK(trace({1, 2, 3, 4, 5, 6, 7, 8, 9}, 3) == 15, std::format("trace = {}", trace({1, 2, 3, 4, 5, 6, 7, 8, 9}, 3)));
    CHECK(sum_firsts({{1, 100}, {2, 200}, {3, 300}}) == 6, "sum_firsts");
    return koan_finish();
}
""",
    ),
]
