enum ShapeKind { SHAPE_CIRCLE, SHAPE_RECT };

struct Shape {
    enum ShapeKind kind;
    union {
        struct { double r; } circle;
        struct { double w, h; } rect;
    };
};

struct Shape make_circle(double r) {
    (void)r;
    return (struct Shape){0};
}

struct Shape make_rect(double w, double h) {
    (void)w; (void)h;
    return (struct Shape){0};
}

double area(struct Shape s) {
    (void)s;
    return 0;
}
