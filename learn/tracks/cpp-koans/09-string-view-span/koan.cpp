#include <numeric>
#include <span>
#include <string_view>
#include <vector>

std::string_view trim(std::string_view text) {
    return text;
}

std::vector<std::string_view> split(std::string_view text, char sep) {
    (void)text; (void)sep;
    return {};
}

long sum_middle(std::span<const int> values) {
    (void)values;
    return 0;
}
