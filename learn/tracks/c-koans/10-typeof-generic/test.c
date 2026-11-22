#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


int main(void) {
    int a = 1, b = 2;
    SWAP(a, b);
    double x = 1.5, y = -2.5;
    SWAP(x, y);
    CHECK(a == 2 && b == 1 && x == -2.5 && y == 1.5, "SWAP works on ints and doubles");
    char *s = "hi";
    CHECK(strcmp(TYPE_NAME(42), "int") == 0 && strcmp(TYPE_NAME(4.2), "double") == 0, "TYPE_NAME(42) = %s", TYPE_NAME(42));
    CHECK(strcmp(TYPE_NAME(s), "char *") == 0 && strcmp(TYPE_NAME('c' + 0L), "other") == 0, "TYPE_NAME(char*)");
    CHECK(ABS(-3) == 3 && ABS(-4L) == 4L && ABS(-2.5) == 2.5, "ABS dispatches by type");
    return koan_finish();
}
