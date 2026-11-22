enum Dir { NORTH, EAST, SOUTH, WEST };  // TODO: give it a 1-byte underlying type (C23)

enum Dir turn_right(enum Dir d) {
    return d;
}

enum Dir opposite(enum Dir d) {
    return d;
}

const char *dir_name(enum Dir d) {
    (void)d;
    return "?";
}
