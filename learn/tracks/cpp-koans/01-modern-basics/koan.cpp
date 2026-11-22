#include <algorithm>
#include <format>
#include <map>
#include <string>
#include <utility>
#include <vector>

std::pair<int, int> min_max(const std::vector<int>& values) {
    return {0, 0};  // TODO: std::ranges::minmax + structured bindings
}

int total(const std::map<std::string, int>& counts) {
    return 0;
}

std::string row(const std::string& name, int count) {
    return name + "|" + std::to_string(count);
}
