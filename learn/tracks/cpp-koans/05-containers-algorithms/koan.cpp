#include <algorithm>
#include <functional>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

std::unordered_map<std::string, int> word_freq(const std::vector<std::string>& words) {
    (void)words;
    return {};
}

std::vector<std::string> top_k(const std::unordered_map<std::string, int>& freq, std::size_t k) {
    (void)freq; (void)k;
    return {};
}

void drop_negatives(std::vector<int>& values) {
    (void)values;  // TODO: std::erase_if
}

long product(const std::vector<int>& values) {
    (void)values;
    return 0;
}
