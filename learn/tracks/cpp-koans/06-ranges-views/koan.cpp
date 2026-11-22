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
    (void)values;
    return {};
}

std::vector<int> first_primes(int n) {
    (void)n;
    return {};
}

long dot(const std::vector<int>& a, const std::vector<int>& b) {
    (void)a; (void)b;
    return 0;
}
