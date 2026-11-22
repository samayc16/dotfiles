enum ShapeKind { SHAPE_CIRCLE, SHAPE_RECT };

struct Shape {
    enum ShapeKind kind;
    union {
        struct { double r; } circle;
        struct { double w, h; } rect;
    };
};

struct Shape make_circle(double r) {
    return (struct Shape){.kind = SHAPE_CIRCLE, .circle = {.r = r}};
}

struct Shape make_rect(double w, double h) {
    return (struct Shape){.kind = SHAPE_RECT, .rect = {.w = w, .h = h}};
}

double area(struct Shape s) {
    switch (s.kind) {
    case SHAPE_CIRCLE: return 3.141592653589793 * s.circle.r * s.circle.r;
    case SHAPE_RECT: return s.rect.w * s.rect.h;
    }
    return 0;
}
