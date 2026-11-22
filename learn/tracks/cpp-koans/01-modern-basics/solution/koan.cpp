#include <algorithm>
#include <format>
#include <map>
#include <string>
#include <utility>
#include <vector>

std::pair<int, int> min_max(const std::vector<int>& values) {
    const auto [lo, hi] = std::ranges::minmax(values);
    return {lo, hi};
}

int total(const std::map<std::string, int>& counts) {
    int sum = 0;
    for (const auto& [name, count] : counts) {
        sum += count;
    }
    return sum;
}

std::string row(const std::string& name, int count) {
    return std::format("{:<6}|{:>4}", name, count);
}
