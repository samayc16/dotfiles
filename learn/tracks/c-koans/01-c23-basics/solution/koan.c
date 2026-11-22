#include <stddef.h>

constexpr unsigned MASK = 0b1111'0000;

size_t count_true(const bool *flags, size_t n) {
    size_t count = 0;
    for (size_t i = 0; i < n; i++) {
        count += flags[i];
    }
    return count;
}

const int *first_positive(const int *xs, size_t n) {
    for (size_t i = 0; i < n; i++) {
        if (xs[i] > 0) {
            return &xs[i];
        }
    }
    return nullptr;
}
