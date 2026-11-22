#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


int main() {
    CHECK((evens_squared({1, 2, 3, 4, 5, 6}) == std::vector<int>{4, 16, 36}), "evens squared");
    CHECK((first_primes(6) == std::vector<int>{2, 3, 5, 7, 11, 13}), "first 6 primes");
    CHECK(dot({1, 2, 3}, {4, 5, 6}) == 32, std::format("dot = {}", dot({1, 2, 3}, {4, 5, 6})));
    CHECK(dot({1, 2, 3}, {10}) == 10, "zip stops at the shorter range");
    return koan_finish();
}
