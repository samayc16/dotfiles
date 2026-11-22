#include <format>
#include <string>

struct Point {
    int x;
    int y;
};

template <>
struct std::formatter<Point> : std::formatter<std::string> {
    auto format(const Point& p, std::format_context& ctx) const {
        return std::formatter<std::string>::format(std::format("({}, {})", p.x, p.y), ctx);
    }
};

std::string hex_and_binary(int value) {
    return std::format("{:#x} {:08b}", value, value);
}

std::string banner(const std::string& text) {
    return std::format("{:*^9}", text);
}

std::string describe(const Point& p) {
    return std::format("point {}", p);
}
