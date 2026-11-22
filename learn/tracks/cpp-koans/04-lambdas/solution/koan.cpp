#include <algorithm>
#include <functional>
#include <vector>

std::function<int()> make_counter() {
    return [count = 0]() mutable { return ++count; };
}

void sum_with(const std::vector<int>& values, int& total) {
    std::ranges::for_each(values, [&total](int v) { total += v; });
}

inline auto add = [](auto a, auto b) { return a + b; };

auto compose(auto f, auto g) {
    return [=](auto x) { return f(g(x)); };
}
