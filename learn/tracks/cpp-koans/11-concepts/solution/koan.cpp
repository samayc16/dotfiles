#include <concepts>

template <class T>
concept Shape = requires(const T& shape) {
    { shape.area() } -> std::convertible_to<double>;
};

template <class T>
concept Number = std::integral<T> || std::floating_point<T>;

template <Shape... Ts>
double total_area(const Ts&... shapes) {
    return (0.0 + ... + shapes.area());
}

template <Number T>
T clamp_to(T value, T low, T high) {
    return value < low ? low : (high < value ? high : value);
}

struct Square {
    double side;
    [[nodiscard]] double area() const { return side * side; }
};

struct Circle {
    double r;
    [[nodiscard]] double area() const { return 3.0 * r * r; }  // engineer's pi
};
