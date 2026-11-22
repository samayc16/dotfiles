struct Point {
    double x;
    double y;
};

struct Rect {
    struct Point min;
    struct Point max;
};

struct Point midpoint(struct Point a, struct Point b) {
    (void)b;
    return a;
}

double rect_area(struct Rect r) {
    (void)r;
    return 0;
}

struct Rect unit_square(void) {
    return (struct Rect){0};
}
