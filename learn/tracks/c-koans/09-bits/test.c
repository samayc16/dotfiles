#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


int main(void) {
    CHECK(is_power_of_two(64) && !is_power_of_two(0) && !is_power_of_two(96), "is_power_of_two");
    CHECK(set_bit(0b0001, 3) == 0b1001, "set_bit");
    CHECK(clear_bit(0b1111, 1) == 0b1101, "clear_bit");
    CHECK(toggle_bit(toggle_bit(0b1010, 0), 3) == 0b0011, "toggle_bit");
    CHECK(popcount(0xF0F0u) == 8 && popcount(0) == 0, "popcount(0xF0F0) = %u", popcount(0xF0F0u));
    CHECK(extract_field(0xABCD1234u, 16, 8) == 0xCD, "extract_field = 0x%X", extract_field(0xABCD1234u, 16, 8));
    return koan_finish();
}
