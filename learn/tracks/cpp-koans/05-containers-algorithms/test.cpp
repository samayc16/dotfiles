#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


int main() {
    auto freq = word_freq({"rg", "sed", "rg", "awk", "sed", "rg"});
    CHECK(freq["rg"] == 3 && freq["awk"] == 1, "counts");
    auto top = top_k(freq, 2);
    CHECK((top == std::vector<std::string>{"rg", "sed"}), "top 2 = rg, sed");
    auto tied = top_k(word_freq({"b", "a", "c"}), 2);
    CHECK((tied == std::vector<std::string>{"a", "b"}), "ties break alphabetically");
    std::vector<int> v{3, -1, 4, -1, 5};
    drop_negatives(v);
    CHECK((v == std::vector<int>{3, 4, 5}), "negatives removed");
    CHECK(product({2, 3, 7}) == 42 && product({}) == 1, "fold_left product");
    return koan_finish();
}
