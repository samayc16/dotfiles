#include <koan_test.hpp>
#include <koan.cpp>  // <...> so the workspace copy (-I) wins
#include <format>


int main() {
    List list;
    for (int i = 0; i < 5; ++i) list.push_front(i);
    CHECK(list.length() == 5, std::format("length = {}", list.length()));
    CHECK(list.head && list.head->value == 4, "push_front puts the newest first");
    auto shared = std::make_shared<int>(7);
    auto copy = shared;
    CHECK(shared.use_count() == 2, "two owners");
    auto watcher = make_observer(shared);
    CHECK(!watcher.expired() && *watcher.lock() == 7, "weak_ptr can lock() while owners exist");
    shared.reset();
    copy.reset();
    CHECK(watcher.expired(), "once the last owner is gone, the weak_ptr expires");
    return koan_finish();
}
