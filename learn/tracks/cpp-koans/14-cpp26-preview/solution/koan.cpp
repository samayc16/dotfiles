#include <cstddef>
#include <mdspan>
#include <utility>
#include <vector>

template <class... Ts>
constexpr auto first(Ts... values) {
    return values...[0];
}

template <class... Ts>
constexpr auto last(Ts... values) {
    return values...[sizeof...(values) - 1];
}

inline int process(int x) { return x * 2; }
int process(double) = delete("process() takes integers; round explicitly");

int trace(const std::vector<int>& data, std::size_t n) {
    std::mdspan matrix(data.data(), n, n);
    int sum = 0;
    for (std::size_t i = 0; i < n; ++i) {
        sum += matrix[i, i];
    }
    return sum;
}

int sum_firsts(const std::vector<std::pair<int, int>>& pairs) {
    int sum = 0;
    for (const auto& [a, _] : pairs) {
        sum += a;
    }
    return sum;
}
