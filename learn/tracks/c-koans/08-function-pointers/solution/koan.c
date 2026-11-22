#include <stdlib.h>

typedef int (*BinOp)(int, int);
typedef int (*UnaryFn)(int);

static int add(int a, int b) { return a + b; }
static int sub(int a, int b) { return a - b; }
static int mul(int a, int b) { return a * b; }

void map_inplace(int *xs, size_t n, UnaryFn f) {
    for (size_t i = 0; i < n; i++) {
        xs[i] = f(xs[i]);
    }
}

BinOp op_for(char symbol) {
    switch (symbol) {
    case '+': return add;
    case '-': return sub;
    case '*': return mul;
    default: return nullptr;
    }
}

static int cmp_desc(const void *a, const void *b) {
    const int x = *(const int *)a;
    const int y = *(const int *)b;
    return (x < y) - (x > y);
}

void sort_desc(int *xs, size_t n) { qsort(xs, n, sizeof *xs, cmp_desc); }
