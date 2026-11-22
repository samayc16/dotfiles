#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


#include <type_traits>
static_assert(!std::is_convertible_v<Level, int>, "make Level an enum class (no implicit int conversion)");
static_assert(sizeof(Level) == 1, "give Level a std::uint8_t underlying type");

int main() {
    CHECK(severity(Level::Warn) == 2, "severity(Warn) == 2");
    CHECK(label(Level::Error) == "ERR" && label(Level::Debug) == "DBG", "labels");
    return koan_finish();
}
