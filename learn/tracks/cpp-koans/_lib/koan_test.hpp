// Tiny koan harness: CHECK(cond, message) prints ✓/✗ and counts failures.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>

inline int koan_total = 0;
inline int koan_failed = 0;

inline const char *koan_color(const char *code) { return std::getenv("NO_COLOR") ? "" : code; }

#define CHECK(cond, message)                                                                     \
    do {                                                                                         \
        ++koan_total;                                                                            \
        if (cond) {                                                                              \
            std::printf("  %s✓%s %s\n", koan_color("\033[38;2;169;220;118m"), koan_color("\033[0m"), #cond); \
        } else {                                                                                 \
            ++koan_failed;                                                                       \
            std::printf("  %s✗%s %s — %s\n", koan_color("\033[38;2;255;97;136m"), koan_color("\033[0m"), #cond, \
                        std::string(message).c_str());                                           \
        }                                                                                        \
        std::fflush(stdout); /* a sanitizer abort must not swallow the lines already printed */  \
    } while (0)

inline int koan_finish() {
    std::printf("\n  %d/%d checks passing\n", koan_total - koan_failed, koan_total);
    return koan_failed ? 1 : 0;
}
