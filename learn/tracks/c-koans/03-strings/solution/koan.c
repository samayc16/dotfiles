#include <ctype.h>
#include <stddef.h>
#include <stdio.h>

size_t my_strlen(const char *s) {
    const char *p = s;
    while (*p != '\0') {
        p++;
    }
    return (size_t)(p - s);
}

bool copy_bounded(char *dst, size_t cap, const char *src) {
    int wanted = snprintf(dst, cap, "%s", src);
    return wanted < 0 || (size_t)wanted >= cap;
}

size_t count_words(const char *s) {
    size_t words = 0;
    bool in_word = false;
    for (; *s != '\0'; s++) {
        bool space = isspace((unsigned char)*s);
        if (!space && !in_word) {
            words++;
        }
        in_word = !space;
    }
    return words;
}

void to_upper(char *s) {
    for (; *s != '\0'; s++) {
        *s = (char)toupper((unsigned char)*s);
    }
}
