#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


#include <string>
static_assert(Shape<Square> && Shape<Circle>, "Square and Circle are Shapes");
static_assert(!Shape<int> && !Shape<std::string>, "int and string are not Shapes: constrain the concept");
static_assert(Number<int> && Number<double> && !Number<std::string>, "Number = integral or floating point");

int main() {
    CHECK(total_area(Square{2}, Circle{1}, Square{1}) == 8.0, std::format("total = {}", total_area(Square{2}, Circle{1}, Square{1})));
    CHECK(clamp_to(15, 0, 10) == 10 && clamp_to(-2.5, -1.0, 1.0) == -1.0, "clamp_to");
    return koan_finish();
}
