#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


#include <stddef.h>
static_assert(sizeof(struct Packet) == 8, "struct Packet has padding: reorder its fields (largest first)");

int main(void) {
    struct Packet p = {.id = 7, .length = 512, .flags = 1, .version = 2};
    CHECK(p.id == 7 && p.length == 512 && p.flags == 1 && p.version == 2, "fields keep their types and values");
    CHECK(offsetof(struct Packet, id) == 0, "id first (largest alignment)");
    return koan_finish();
}
