#include <stdint.h>

struct Packet {
    uint32_t id;
    uint16_t length;
    uint8_t flags;
    uint8_t version;
};
