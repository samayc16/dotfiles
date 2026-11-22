#include <cstdint>
#include <string_view>
#include <utility>

enum class Level : std::uint8_t { Debug, Info, Warn, Error };

int severity(Level level) {
    return std::to_underlying(level);
}

std::string_view label(Level level) {
    switch (level) {
        using enum Level;
    case Debug: return "DBG";
    case Info: return "INF";
    case Warn: return "WRN";
    case Error: return "ERR";
    }
    return "?";
}
