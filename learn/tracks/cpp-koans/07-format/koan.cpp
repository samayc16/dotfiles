#include <format>
#include <string>

struct Point {
    int x;
    int y;
};

// TODO: specialize std::formatter<Point>

std::string hex_and_binary(int value) {
    return std::to_string(value);
}

std::string banner(const std::string& text) {
    return text;
}

std::string describe(const Point& p) {
    (void)p;
    return "?";
}
