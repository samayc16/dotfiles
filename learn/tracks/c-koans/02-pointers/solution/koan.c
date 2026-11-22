#include <stddef.h>

void swap(int *a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

long sum(const int *xs, size_t n) {
    long total = 0;
    for (const int *p = xs; p < xs + n; p++) {
        total += *p;
    }
    return total;
}

void reverse(int *xs, size_t n) {
    if (n < 2) {
        return;
    }
    for (int *lo = xs, *hi = xs + n - 1; lo < hi; lo++, hi--) {
        swap(lo, hi);
    }
}

int *max_element(int *xs, size_t n) {
    if (n == 0) {
        return nullptr;
    }
    int *best = xs;
    for (int *p = xs + 1; p < xs + n; p++) {
        if (*p > *best) {
            best = p;
        }
    }
    return best;
}
