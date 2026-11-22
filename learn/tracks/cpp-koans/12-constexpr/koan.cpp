#include <array>

long factorial(int n) {  // TODO: constexpr
    return n <= 1 ? 1 : n * factorial(n - 1);
}

int square(int x) { return x * x; }  // TODO: consteval

constexpr std::array<int, 10> make_squares() {
    std::array<int, 10> table{};
    // TODO: fill table[i] = i * i
    return table;
}

constexpr auto squares = make_squares();
