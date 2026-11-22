#include <stdlib.h>

typedef int (*BinOp)(int, int);
typedef int (*UnaryFn)(int);

static int add(int a, int b) { return a + b; }
static int sub(int a, int b) { return a - b; }
static int mul(int a, int b) { return a * b; }

void map_inplace(int *xs, size_t n, UnaryFn f) {
    (void)xs; (void)n; (void)f;  // TODO
}

BinOp op_for(char symbol) {
    (void)symbol; (void)add; (void)sub; (void)mul;
    return nullptr;
}

static int cmp_desc(const void *a, const void *b) { (void)a; (void)b; return 0; }

void sort_desc(int *xs, size_t n) { qsort(xs, n, sizeof *xs, cmp_desc); }
