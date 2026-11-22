#include <cstddef>
#include <memory>

struct Node {
    int value;
    std::unique_ptr<Node> next;
    explicit Node(int v) : value{v} {}
};

struct List {
    std::unique_ptr<Node> head;

    void push_front(int value) {
        (void)value;  // TODO: make_unique + move
    }

    [[nodiscard]] std::size_t length() const {
        return 0;
    }
};

std::weak_ptr<int> make_observer(const std::shared_ptr<int>& shared) {
    (void)shared;
    return {};
}
