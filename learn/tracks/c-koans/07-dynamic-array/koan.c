#include <stdlib.h>

struct IntVec {
    int *data;
    size_t len;
    size_t cap;
};

bool vec_push(struct IntVec *v, int value) {
    v->data[v->len++] = value;  // TODO: this writes past the end! grow first
    return true;
}

int *vec_get(struct IntVec *v, size_t i) {
    return &v->data[i];  // TODO: bounds check
}

void vec_free(struct IntVec *v) {
    (void)v;  // TODO
}
