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
    return values | std::views::filter([](int x) { return x % 2 == 0; }) |
           std::views::transform([](int x) { return x * x; }) | std::ranges::to<std::vector>();
}

std::vector<int> first_primes(int n) {
    return std::views::iota(2) | std::views::filter(is_prime) | std::views::take(n) | std::ranges::to<std::vector>();
}

long dot(const std::vector<int>& a, const std::vector<int>& b) {
    long sum = 0;
    for (const auto [x, y] : std::views::zip(a, b)) {
        sum += static_cast<long>(x) * y;
    }
    return sum;
}
