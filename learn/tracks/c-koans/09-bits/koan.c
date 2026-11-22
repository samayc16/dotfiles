#include <stdint.h>

bool is_power_of_two(uint32_t x) {
    (void)x;
    return false;
}

uint32_t set_bit(uint32_t x, unsigned i) {
    (void)i;
    return x;
}

uint32_t clear_bit(uint32_t x, unsigned i) {
    (void)i;
    return x;
}

uint32_t toggle_bit(uint32_t x, unsigned i) {
    (void)i;
    return x;
}

unsigned popcount(uint32_t x) {
    (void)x;
    return 0;
}

uint32_t extract_field(uint32_t x, unsigned pos, unsigned width) {
    (void)x; (void)pos; (void)width;
    return 0;
}
