#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


int main() {
    CHECK(hex_and_binary(255) == "0xff 11111111", std::format("got '{}'", hex_and_binary(255)));
    CHECK(banner("ok") == "***ok****", std::format("got '{}'", banner("ok")));
    CHECK(describe({3, -4}) == "point (3, -4)", std::format("got '{}'", describe({3, -4})));
    return koan_finish();
}
