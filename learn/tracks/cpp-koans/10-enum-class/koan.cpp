#include <cstdint>
#include <string_view>
#include <utility>

enum Level { Debug, Info, Warn, Error };  // TODO: scoped, 1 byte

int severity(Level level) {
    (void)level;
    return -1;
}

std::string_view label(Level level) {
    (void)level;
    return "?";
}
