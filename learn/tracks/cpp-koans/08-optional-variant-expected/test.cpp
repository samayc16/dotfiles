#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


int main() {
    CHECK(parse_int("42") == 42 && !parse_int("4x2") && !parse_int(""), "parse_int");
    CHECK(kind_of(Value{7}) == "int 7" && kind_of(Value{2.5}) == "double", "visit int/double");
    CHECK(kind_of(Value{std::string{"vim"}}) == "string of 3", "visit string");
    CHECK(safe_div(9, 3) == 3, "9 / 3");
    auto bad = safe_div(1, 0);
    CHECK(!bad && bad.error() == "divide by zero", "division by zero is an error value");
    CHECK(half_of_parsed("10") == 5, "chain parse -> divide");
    CHECK(!half_of_parsed("ten") && half_of_parsed("ten").error() == "not a number", "parse failure propagates");
    return koan_finish();
}
