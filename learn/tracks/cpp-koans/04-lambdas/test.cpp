#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


#include <string>

int main() {
    auto next = make_counter();
    next();
    next();
    CHECK(next() == 3, "third call returns 3");
    int total = 10;
    sum_with({1, 2, 3}, total);
    CHECK(total == 16, std::format("total = {}", total));
    CHECK(add(1.5, 2.0) == 3.5 && add(std::string{"ab"}, std::string{"c"}) == "abc", "add is generic");
    auto inc_then_double = compose([](int x) { return x * 2; }, [](int x) { return x + 1; });
    CHECK(inc_then_double(4) == 10, std::format("got {}", inc_then_double(4)));
    return koan_finish();
}
