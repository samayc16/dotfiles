#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


#include <type_traits>
#include <vector>

static_assert(!std::is_copy_constructible_v<Buffer>, "Buffer owns memory: delete its copy constructor");

int main() {
    Buffer a{8};
    a.data()[3] = 42;
    Buffer b{std::move(a)};
    CHECK(b.size() == 8 && b.data()[3] == 42, "b took over a's array");
    CHECK(a.size() == 0 && a.data() == nullptr, "moved-from a is empty");
    Buffer c{2};
    c = std::move(b);
    CHECK(c.size() == 8 && b.data() == nullptr, "move assignment transfers ownership");
    CHECK(std::is_nothrow_move_constructible_v<Buffer>, "mark the move constructor noexcept (std::vector relies on it)");
    std::vector<Buffer> many;
    for (int i = 0; i < 20; ++i) many.emplace_back(4);  // reallocations move, never copy
    CHECK(many.size() == 20, "vector of move-only Buffers");
    return koan_finish();
}
