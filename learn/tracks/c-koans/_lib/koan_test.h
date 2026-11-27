/* Tiny koan harness: CHECK(cond, fmt, ...) prints ✓/✗ and counts failures. */
#pragma once
#include <stdio.h>
#include <stdlib.h>

static int koan_total_ = 0;
static int koan_failed_ = 0;

static inline const char *koan_color_(const char *code) { return getenv("NO_COLOR") ? "" : code; }

#define CHECK(cond, ...)                                                                    \
    do {                                                                                    \
        koan_total_++;                                                                      \
        if (cond) {                                                                         \
            printf("  %s✓%s %s\n", koan_color_("\033[38;2;169;220;118m"), koan_color_("\033[0m"), #cond); \
        } else {                                                                            \
            koan_failed_++;                                                                 \
            printf("  %s✗%s %s — ", koan_color_("\033[38;2;255;97;136m"), koan_color_("\033[0m"), #cond); \
            printf(__VA_ARGS__);                                                            \
            printf("\n");                                                                   \
        }                                                                                   \
        fflush(stdout); /* a sanitizer abort must not swallow the lines already printed */  \
    } while (0)

static inline int koan_finish(void) {
    printf("\n  %d/%d checks passing\n", koan_total_ - koan_failed_, koan_total_);
    return koan_failed_ ? 1 : 0;
}
