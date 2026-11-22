#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


int main(void) {
    struct IntVec v = {0};
    bool ok = true;
    for (int i = 0; i < 1000; i++) {
        ok = ok && vec_push(&v, i * i);
    }
    CHECK(ok && v.len == 1000 && v.cap >= 1000, "len=%zu cap=%zu", v.len, v.cap);
    CHECK(v.cap < 4096, "grow geometrically (doubling), not to some huge fixed size: cap=%zu", v.cap);
    CHECK(vec_get(&v, 999) && *vec_get(&v, 999) == 998001, "vec_get(999)");
    CHECK(vec_get(&v, 1000) == nullptr, "out of range -> nullptr");
    vec_free(&v);
    CHECK(v.data == nullptr && v.len == 0 && v.cap == 0, "vec_free resets the struct");
    return koan_finish();
}
