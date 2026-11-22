#include <stdint.h>

struct Packet {
    uint8_t flags;
    uint32_t id;
    uint8_t version;
    uint16_t length;
};
