#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


int main(void) {
    CHECK(MASK == 240u, "MASK should be 0b1111'0000 (240), got %u", (unsigned)MASK);
    bool flags[] = {true, false, true, true};
    CHECK(count_true(flags, 4) == 3, "expected 3, got %zu", count_true(flags, 4));
    int xs[] = {-3, 0, 7, 9};
    const int *p = first_positive(xs, 4);
    CHECK(p == &xs[2], "should point at xs[2] (the 7)");
    int neg[] = {-1, -2};
    CHECK(first_positive(neg, 2) == nullptr, "no positives: return nullptr");
    return koan_finish();
}
