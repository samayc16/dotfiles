#include <charconv>
#include <expected>
#include <optional>
#include <string>
#include <string_view>
#include <variant>

std::optional<int> parse_int(std::string_view text) {
    int value = 0;
    const auto [ptr, ec] = std::from_chars(text.data(), text.data() + text.size(), value);
    if (ec != std::errc{} || ptr != text.data() + text.size() || text.empty()) {
        return std::nullopt;
    }
    return value;
}

template <class... Fs>
struct overloaded : Fs... {
    using Fs::operator()...;
};

using Value = std::variant<int, double, std::string>;

std::string kind_of(const Value& v) {
    return std::visit(overloaded{
                          [](int i) { return "int " + std::to_string(i); },
                          [](double) { return std::string{"double"}; },
                          [](const std::string& s) { return "string of " + std::to_string(s.size()); },
                      },
                      v);
}

std::expected<int, std::string> safe_div(int a, int b) {
    if (b == 0) {
        return std::unexpected{"divide by zero"};
    }
    return a / b;
}

std::expected<int, std::string> half_of_parsed(std::string_view text) {
    auto parsed = parse_int(text);
    if (!parsed) {
        return std::unexpected{"not a number"};
    }
    return safe_div(*parsed, 2).transform([](int half) { return half; });
}
