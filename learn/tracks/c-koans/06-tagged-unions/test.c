#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


#include <math.h>
int main(void) {
    struct Shape c = make_circle(2);
    CHECK(c.kind == SHAPE_CIRCLE && c.circle.r == 2, "make_circle sets kind + radius");
    CHECK(fabs(area(c) - 12.566370614359172) < 1e-9, "circle area = %f", area(c));
    struct Shape r = make_rect(3, 4);
    CHECK(r.kind == SHAPE_RECT && area(r) == 12, "rect area = %f", area(r));
    CHECK(sizeof(struct Shape) <= 24, "the union shares storage: sizeof = %zu", sizeof(struct Shape));
    return koan_finish();
}
