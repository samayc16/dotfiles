#include <numeric>
#include <span>
#include <string_view>
#include <vector>

std::string_view trim(std::string_view text) {
    constexpr std::string_view ws = " \t\n";
    const auto first = text.find_first_not_of(ws);
    if (first == std::string_view::npos) {
        return {};
    }
    const auto last = text.find_last_not_of(ws);
    return text.substr(first, last - first + 1);
}

std::vector<std::string_view> split(std::string_view text, char sep) {
    std::vector<std::string_view> parts;
    while (true) {
        const auto pos = text.find(sep);
        parts.push_back(text.substr(0, pos));
        if (pos == std::string_view::npos) {
            return parts;
        }
        text.remove_prefix(pos + 1);
    }
}

long sum_middle(std::span<const int> values) {
    if (values.size() < 3) {
        return 0;
    }
    const auto middle = values.subspan(1, values.size() - 2);
    return std::accumulate(middle.begin(), middle.end(), 0L);
}
