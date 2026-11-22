#include <array>

constexpr long factorial(int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}

consteval int square(int x) { return x * x; }

constexpr std::array<int, 10> make_squares() {
    std::array<int, 10> table{};
    for (int i = 0; i < 10; ++i) {
        table[i] = i * i;
    }
    return table;
}

constexpr auto squares = make_squares();
