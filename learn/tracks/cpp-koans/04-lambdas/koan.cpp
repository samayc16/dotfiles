#include <algorithm>
#include <functional>
#include <vector>

std::function<int()> make_counter() {
    return [] { return 0; };  // TODO: remember a count between calls
}

void sum_with(const std::vector<int>& values, int& total) {
    (void)values; (void)total;  // TODO: std::ranges::for_each + capture total by reference
}

inline auto add = [](int a, int b) { return a + b; };  // TODO: make it generic (works for doubles and strings)

auto compose(auto f, auto g) {
    return f;
}
