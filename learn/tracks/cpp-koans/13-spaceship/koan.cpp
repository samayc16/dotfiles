#include <algorithm>
#include <cctype>
#include <compare>
#include <string>

struct Version {
    int major;
    int minor;
    int patch;
    // TODO: default the three-way comparison
};

inline std::string lower(std::string s) {
    std::ranges::transform(s, s.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return s;
}

struct CiString {
    std::string text;
    // TODO: operator<=> returning std::weak_ordering, and operator==, both case-insensitive
};
