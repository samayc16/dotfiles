#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


static_assert(factorial(10) == 3628800, "factorial must be constexpr and correct");
static_assert(square(12) == 144, "square must be usable at compile time");
static_assert(squares[9] == 81 && squares[3] == 9, "the table is built at compile time");

int main() {
    CHECK(factorial(5) == 120, "runtime call works too");
    return koan_finish();
}
