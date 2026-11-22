#include <stdlib.h>

struct IntVec {
    int *data;
    size_t len;
    size_t cap;
};

bool vec_push(struct IntVec *v, int value) {
    if (v->len == v->cap) {
        size_t new_cap = v->cap ? v->cap * 2 : 4;
        int *grown = realloc(v->data, new_cap * sizeof *grown);
        if (grown == nullptr) {
            return false;
        }
        v->data = grown;
        v->cap = new_cap;
    }
    v->data[v->len++] = value;
    return true;
}

int *vec_get(struct IntVec *v, size_t i) {
    return i < v->len ? &v->data[i] : nullptr;
}

void vec_free(struct IntVec *v) {
    free(v->data);
    *v = (struct IntVec){0};
}
