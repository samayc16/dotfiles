#include <stddef.h>

#define MASK 0  // TODO: a C23 constexpr unsigned, written as a binary literal with a digit separator

size_t count_true(const bool *flags, size_t n) {
    (void)flags; (void)n;
    return 0;
}

const int *first_positive(const int *xs, size_t n) {
    (void)xs; (void)n;
    return xs;
}
