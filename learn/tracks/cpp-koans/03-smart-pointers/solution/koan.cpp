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
        auto node = std::make_unique<Node>(value);
        node->next = std::move(head);
        head = std::move(node);
    }

    [[nodiscard]] std::size_t length() const {
        std::size_t count = 0;
        for (const Node* n = head.get(); n != nullptr; n = n->next.get()) {
            ++count;
        }
        return count;
    }
};

std::weak_ptr<int> make_observer(const std::shared_ptr<int>& shared) {
    return shared;
}
