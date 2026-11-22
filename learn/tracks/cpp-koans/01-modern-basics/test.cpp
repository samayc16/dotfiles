#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


int main() {
    const auto [lo, hi] = min_max({4, -2, 9, 0});
    CHECK(lo == -2 && hi == 9, std::format("got {{{}, {}}}", lo, hi));
    CHECK(total({{"vim", 7}, {"awk", 3}}) == 10, "sum of values");
    CHECK(row("vim", 7) == "vim   |   7", std::format("got '{}'", row("vim", 7)));
    return koan_finish();
}
