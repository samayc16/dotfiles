#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


#include <vector>
int main() {
    std::vector<Version> vs{{1, 10, 0}, {1, 2, 3}, {0, 9, 9}};
    std::ranges::sort(vs);
    CHECK(vs.front() == (Version{0, 9, 9}) && vs.back() == (Version{1, 10, 0}), "sorted versions");
    CHECK((Version{1, 2, 3} < Version{1, 3, 0}), "<");
    CHECK((CiString{"Vim"} == CiString{"vIM"}), "case-insensitive equality");
    CHECK((CiString{"awk"} < CiString{"SED"}), "case-insensitive ordering");
    return koan_finish();
}
