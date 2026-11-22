#include <concepts>

template <class T> concept Shape = true;  // TODO: require a const area() returning something convertible to double

template <class T> concept Number = true;  // TODO: integral or floating point

template <Shape... Ts>
double total_area(const Ts&... shapes) {
    return 0;  // TODO: fold expression
}

template <Number T>
T clamp_to(T value, T low, T high) {
    (void)low; (void)high;
    return value;
}

struct Square {
    double side;
    [[nodiscard]] double area() const { return side * side; }
};

struct Circle {
    double r;
    [[nodiscard]] double area() const { return 3.0 * r * r; }  // engineer's pi
};
