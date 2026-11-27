#include <koan_test.h>
#include <koan.c>  /* <...> so the workspace copy (-I) wins */
#include <string.h>


int main(void) {
    CHECK(my_strlen("grep") == 4 && my_strlen("") == 0, "my_strlen(\"grep\") = %zu", my_strlen("grep"));
    char small[5] = "";  // zeroed, so a copy_bounded that writes nothing fails the check, not the harness
    bool truncated = copy_bounded(small, sizeof small, "awkward");
    CHECK(truncated && strcmp(small, "awkw") == 0, "got \"%s\" truncated=%d", small, truncated);
    char big[16] = "";
    CHECK(!copy_bounded(big, sizeof big, "sed") && strcmp(big, "sed") == 0, "fits: no truncation");
    CHECK(count_words("  find . -name  '*.c'  ") == 4, "got %zu words", count_words("  find . -name  '*.c'  "));
    char shout[] = "rg -i todo";
    to_upper(shout);
    CHECK(strcmp(shout, "RG -I TODO") == 0, "got \"%s\"", shout);
    return koan_finish();
}
