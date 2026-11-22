#include <algorithm>
#include <cctype>
#include <compare>
#include <string>

struct Version {
    int major;
    int minor;
    int patch;
    auto operator<=>(const Version&) const = default;
};

inline std::string lower(std::string s) {
    std::ranges::transform(s, s.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return s;
}

struct CiString {
    std::string text;
    std::weak_ordering operator<=>(const CiString& other) const { return lower(text) <=> lower(other.text); }
    bool operator==(const CiString& other) const { return lower(text) == lower(other.text); }
};
