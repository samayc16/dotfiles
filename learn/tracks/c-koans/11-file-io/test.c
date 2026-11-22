#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


#include <unistd.h>
int main(void) {
    const char *path = "koan_io_test.txt";
    const char *lines[] = {"10 20", "30", "", "40"};
    CHECK(write_lines(path, lines, 4), "write_lines returned false");
    CHECK(count_lines(path) == 4, "count_lines = %ld", count_lines(path));
    CHECK(sum_numbers(path) == 100, "sum_numbers = %ld", sum_numbers(path));
    CHECK(count_lines("/definitely/not/here.txt") == -1, "missing file -> -1");
    unlink(path);
    return koan_finish();
}
