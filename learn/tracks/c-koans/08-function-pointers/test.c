#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


static int twice(int x) { return 2 * x; }

int main(void) {
    int xs[] = {1, 2, 3};
    map_inplace(xs, 3, twice);
    CHECK(xs[0] == 2 && xs[2] == 6, "map_inplace(twice) gave %d %d %d", xs[0], xs[1], xs[2]);
    BinOp plus = op_for('+'), times = op_for('*');
    CHECK(plus && plus(2, 3) == 5, "op_for('+')");
    CHECK(times && times(4, 5) == 20, "op_for('*')");
    CHECK(op_for('?') == nullptr, "unknown symbol -> nullptr");
    int ys[] = {3, 1, 4, 1, 5, 9, 2, 6};
    sort_desc(ys, 8);
    CHECK(ys[0] == 9 && ys[7] == 1 && ys[3] == 4, "sorted: %d %d %d %d ...", ys[0], ys[1], ys[2], ys[3]);
    return koan_finish();
}
