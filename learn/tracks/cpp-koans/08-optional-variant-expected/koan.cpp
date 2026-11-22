#include <charconv>
#include <expected>
#include <optional>
#include <string>
#include <string_view>
#include <variant>

std::optional<int> parse_int(std::string_view text) {
    (void)text;
    return 0;
}

template <class... Fs>
struct overloaded : Fs... {
    using Fs::operator()...;
};

using Value = std::variant<int, double, std::string>;

std::string kind_of(const Value& v) {
    (void)v;
    return "?";
}

std::expected<int, std::string> safe_div(int a, int b) {
    return a / b;  // TODO: b == 0 must be an error, not a crash
}

std::expected<int, std::string> half_of_parsed(std::string_view text) {
    (void)text;
    return std::unexpected{"TODO"};
}
