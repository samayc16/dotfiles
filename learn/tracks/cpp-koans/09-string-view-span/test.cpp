#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


#include <array>
int main() {
    CHECK(trim("  \tgrep -n \n") == "grep -n", std::format("got '{}'", trim("  \tgrep -n \n")));
    CHECK(trim("   ").empty(), "all whitespace -> empty");
    auto parts = split("a:b::c", ':');
    CHECK((parts == std::vector<std::string_view>{"a", "b", "", "c"}), "split keeps empty fields");
    std::array<int, 5> arr{100, 1, 2, 3, 100};
    std::vector<int> vec{5, 6, 7};
    CHECK(sum_middle(arr) == 6 && sum_middle(vec) == 6, "span accepts arrays and vectors");
    return koan_finish();
}
