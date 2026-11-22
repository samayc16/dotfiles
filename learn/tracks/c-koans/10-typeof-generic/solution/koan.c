#include <math.h>
#include <stdlib.h>

#define SWAP(a, b)              \
    do {                        \
        typeof(a) swap_tmp_ = (a); \
        (a) = (b);              \
        (b) = swap_tmp_;        \
    } while (0)

#define TYPE_NAME(x) _Generic((x), int: "int", double: "double", char *: "char *", default: "other")

#define ABS(x) _Generic((x), int: abs, long: labs, double: fabs)(x)
