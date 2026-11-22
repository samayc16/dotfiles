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
            "auto [lo, hi] = std::ranges::minmax(v); return {lo, hi};  (std::ranges::minmax returns a struct with .min/.max)",
            "for (const auto& [name, count] : m) total += count;   std::format(\"{:<6}|{:>4}\", name, n)",
        ],
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
            "Without a move constructor, moving falls back to the implicit copy: two Buffers own the same array and both delete it (ASan: double-free).",
            "Buffer(Buffer&& other) noexcept : data_{std::exchange(other.data_, nullptr)}, size_{std::exchange(other.size_, 0)} {}  plus = delete for copies, and a move-assign that deletes[] the old data first.",
        ],
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
            "push_front: auto node = std::make_unique<Node>(value); node->next = std::move(head); head = std::move(node);",
            "length: for (const Node* n = head.get(); n; n = n->next.get()) ++count;  A weak_ptr doesn't keep the object alive: .expired() becomes true once the last shared_ptr dies.",
        ],
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
            "Stateful lambda: return [count = 0]() mutable { return ++count; };  — init-capture + mutable.",
            "Generic: [](auto a, auto b) { return a + b; }.  compose: return [=](auto x) { return f(g(x)); };",
        ],
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
            "word_freq: std::unordered_map<std::string, int> m; for (const auto& w : words) ++m[w];",
            "top_k: copy into a vector<pair>, std::ranges::sort(v, std::greater{}, &std::pair<std::string,int>::second) — the projection picks what to compare. drop_negatives: std::erase_if(v, [](int x) { return x < 0; });",
        ],
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
            "Pipelines read left to right: values | std::views::filter(is_even) | std::views::transform(square) | std::ranges::to<std::vector>()",
            "Infinite source: std::views::iota(2) | std::views::filter(is_prime) | std::views::take(n). zip pairs two ranges: for (auto [a, b] : std::views::zip(xs, ys)).",
        ],
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
            "Specs: {:08.3f} zero-pads, {:#x} hex with 0x, {:08b} 8-digit binary, {:*^9} centres with * fill.",
            "Custom type: template <> struct std::formatter<Point> : std::formatter<std::string> { auto format(const Point& p, auto& ctx) const { return std::formatter<std::string>::format(std::format(\"({}, {})\", p.x, p.y), ctx); } };",
        ],
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
            "parse_int: use std::from_chars(s.data(), s.data() + s.size(), value); success when ec == std::errc{} and ptr == end.",
            "Overloaded visitor: template <class... Fs> struct overloaded : Fs... { using Fs::operator()...; };  std::visit(overloaded{[](int i) {...}, [](const std::string& s) {...}}, v).  Errors: return std::unexpected{\"divide by zero\"};",
        ],
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
            "trim: find_first_not_of(\" \\t\\n\") / find_last_not_of(...) then substr. A string_view never copies.",
            "split: loop with find(sep), push_back(text.substr(0, pos)), text.remove_prefix(pos + 1). span: std::span<const int> s; s.subspan(1, s.size() - 2).",
        ],
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
            "enum class Level : std::uint8_t { Debug, Info, Warn, Error };  scoped: no implicit int conversion.",
            "std::to_underlying(level) gives the integer. Inside a switch: using enum Level; case Debug: ... (C++20).",
        ],
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
            "template <class T> concept Shape = requires(const T& s) { { s.area() } -> std::convertible_to<double>; };",
            "Variadic + fold: template <Shape... Ts> double total_area(const Ts&... shapes) { return (0.0 + ... + shapes.area()); }",
        ],
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
            "constexpr functions run at compile time when given constants: constexpr long factorial(int n) { return n <= 1 ? 1 : n * factorial(n - 1); }",
            "consteval forces compile-time evaluation. A compile-time table: constexpr auto make_squares() { std::array<int, 10> t{}; for (int i = 0; i < 10; ++i) t[i] = i * i; return t; }",
        ],
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
            "auto operator<=>(const Version&) const = default; generates <, <=, >, >= and (with = default ==) equality, member by member.",
            "Case-insensitive: std::weak_ordering operator<=>(const CiString& o) const { return lower(text) <=> lower(o.text); } and bool operator==(const CiString& o) const { return lower(text) == lower(o.text); }",
        ],
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
            "Pack indexing: template <class... Ts> constexpr auto first(Ts... ts) { return ts...[0]; }  last: ts...[sizeof...(ts) - 1].",
            "void process(double) = delete(\"use process(int)\");   mdspan: std::mdspan grid(data, rows, cols); grid[r, c] (multidimensional subscript).",
        ],
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
