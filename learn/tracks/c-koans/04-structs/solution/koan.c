struct Point {
    double x;
    double y;
};

struct Rect {
    struct Point min;
    struct Point max;
};

struct Point midpoint(struct Point a, struct Point b) {
    return (struct Point){.x = (a.x + b.x) / 2, .y = (a.y + b.y) / 2};
}

double rect_area(struct Rect r) {
    return (r.max.x - r.min.x) * (r.max.y - r.min.y);
}

struct Rect unit_square(void) {
    return (struct Rect){.min = {.x = 0, .y = 0}, .max = {.x = 1, .y = 1}};
}
