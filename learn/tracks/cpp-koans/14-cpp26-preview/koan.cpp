#include <cstddef>
#include <mdspan>
#include <utility>
#include <vector>

template <class... Ts>
constexpr auto first(Ts... values) {
    return 0;  // TODO: pack indexing
}

template <class... Ts>
constexpr auto last(Ts... values) {
    return 0;
}

inline int process(int x) { return x * 2; }
// TODO: delete the double overload, with a reason

int trace(const std::vector<int>& data, std::size_t n) {
    (void)data; (void)n;
    return 0;
}

int sum_firsts(const std::vector<std::pair<int, int>>& pairs) {
    (void)pairs;
    return 0;
}
