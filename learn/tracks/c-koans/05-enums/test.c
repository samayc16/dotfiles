#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


int main(void) {
    CHECK(sizeof(enum Dir) == 1, "sizeof(enum Dir) = %zu, want 1", sizeof(enum Dir));
    CHECK(turn_right(WEST) == NORTH && turn_right(NORTH) == EAST, "turn_right wraps around");
    CHECK(opposite(EAST) == WEST && opposite(SOUTH) == NORTH, "opposite");
    CHECK(strcmp(dir_name(SOUTH), "south") == 0, "dir_name(SOUTH) = %s", dir_name(SOUTH));
    return koan_finish();
}
