#include <stdint.h>

bool is_power_of_two(uint32_t x) {
    return x != 0 && (x & (x - 1)) == 0;
}

uint32_t set_bit(uint32_t x, unsigned i) {
    return x | (UINT32_C(1) << i);
}

uint32_t clear_bit(uint32_t x, unsigned i) {
    return x & ~(UINT32_C(1) << i);
}

uint32_t toggle_bit(uint32_t x, unsigned i) {
    return x ^ (UINT32_C(1) << i);
}

unsigned popcount(uint32_t x) {
    unsigned count = 0;
    while (x) {
        x &= x - 1;
        count++;
    }
    return count;
}

uint32_t extract_field(uint32_t x, unsigned pos, unsigned width) {
    return (x >> pos) & ((UINT32_C(1) << width) - 1);
}
