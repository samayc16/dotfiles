#include <stdio.h>
#include <string.h>

bool write_lines(const char *path, const char *const *lines, size_t n) {
    FILE *f = fopen(path, "w");
    if (f == nullptr) {
        return false;
    }
    for (size_t i = 0; i < n; i++) {
        fprintf(f, "%s\n", lines[i]);
    }
    return fclose(f) == 0;
}

long count_lines(const char *path) {
    FILE *f = fopen(path, "r");
    if (f == nullptr) {
        return -1;
    }
    long count = 0;
    char buf[256];
    while (fgets(buf, sizeof buf, f) != nullptr) {
        if (strchr(buf, '\n') != nullptr) {
            count++;
        }
    }
    fclose(f);
    return count;
}

long sum_numbers(const char *path) {
    FILE *f = fopen(path, "r");
    if (f == nullptr) {
        return 0;
    }
    long total = 0, n = 0;
    while (fscanf(f, "%ld", &n) == 1) {
        total += n;
    }
    fclose(f);
    return total;
}
