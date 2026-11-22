#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


int main(void) {
    int a = 1, b = 2;
    swap(&a, &b);
    CHECK(a == 2 && b == 1, "after swap a=%d b=%d", a, b);
    int xs[] = {4, 8, 15, 16, 23, 42};
    CHECK(sum(xs, 6) == 108, "sum = %ld", sum(xs, 6));
    reverse(xs, 6);
    CHECK(xs[0] == 42 && xs[5] == 4 && xs[2] == 16, "reverse gave %d %d .. %d", xs[0], xs[1], xs[5]);
    int one[] = {7};
    reverse(one, 1);
    CHECK(one[0] == 7, "reversing one element is a no-op");
    int ys[] = {3, 9, 2, 9};
    CHECK(max_element(ys, 4) == &ys[1], "should point at the FIRST 9");
    CHECK(max_element(ys, 0) == nullptr, "empty range: nullptr");
    return koan_finish();
}
