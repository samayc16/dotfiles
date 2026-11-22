enum Dir : unsigned char { NORTH, EAST, SOUTH, WEST };

enum Dir turn_right(enum Dir d) {
    return (enum Dir)((d + 1) % 4);
}

enum Dir opposite(enum Dir d) {
    return (enum Dir)((d + 2) % 4);
}

const char *dir_name(enum Dir d) {
    switch (d) {
    case NORTH: return "north";
    case EAST: return "east";
    case SOUTH: return "south";
    case WEST: return "west";
    }
    return "?";
}
