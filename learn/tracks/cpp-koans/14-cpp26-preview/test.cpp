#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


template <class T>
concept CanProcess = requires(T value) { process(value); };
static_assert(CanProcess<int>, "process(int) still works");
static_assert(!CanProcess<double>, "process(double) should be = delete(\"reason\")");
static_assert(first(7, 'x', 2.5) == 7 && last(7, 'x', 2.5) == 2.5, "pack indexing");

int main() {
    CHECK(trace({1, 2, 3, 4, 5, 6, 7, 8, 9}, 3) == 15, std::format("trace = {}", trace({1, 2, 3, 4, 5, 6, 7, 8, 9}, 3)));
    CHECK(sum_firsts({{1, 100}, {2, 200}, {3, 300}}) == 6, "sum_firsts");
    return koan_finish();
}
