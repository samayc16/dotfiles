#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


int main(void) {
    struct Point m = midpoint((struct Point){.x = 0, .y = 0}, (struct Point){.x = 4, .y = 2});
    CHECK(m.x == 2 && m.y == 1, "midpoint = (%g, %g)", m.x, m.y);
    struct Rect r = {.min = {1, 1}, .max = {4, 3}};
    CHECK(rect_area(r) == 6, "area = %g", rect_area(r));
    struct Rect u = unit_square();
    CHECK(u.max.x == 1 && u.max.y == 1 && u.min.x == 0, "unit square max = (%g, %g)", u.max.x, u.max.y);
    return koan_finish();
}
