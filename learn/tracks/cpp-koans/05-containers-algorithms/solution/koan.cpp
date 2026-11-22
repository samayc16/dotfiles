#include <algorithm>
#include <functional>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

std::unordered_map<std::string, int> word_freq(const std::vector<std::string>& words) {
    std::unordered_map<std::string, int> freq;
    for (const auto& word : words) {
        ++freq[word];
    }
    return freq;
}

std::vector<std::string> top_k(const std::unordered_map<std::string, int>& freq, std::size_t k) {
    std::vector<std::pair<std::string, int>> entries(freq.begin(), freq.end());
    std::ranges::sort(entries, [](const auto& a, const auto& b) {
        return a.second != b.second ? a.second > b.second : a.first < b.first;
    });
    std::vector<std::string> out;
    for (const auto& [word, count] : entries) {
        if (out.size() == k) break;
        out.push_back(word);
    }
    return out;
}

void drop_negatives(std::vector<int>& values) {
    std::erase_if(values, [](int x) { return x < 0; });
}

long product(const std::vector<int>& values) {
    return std::ranges::fold_left(values, 1L, std::multiplies{});
}
