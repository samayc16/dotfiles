#include <cstddef>
#include <utility>

class Buffer {
public:
    explicit Buffer(std::size_t size) : data_{new int[size]{}}, size_{size} {}
    ~Buffer() { delete[] data_; }

    // TODO: move constructor, move assignment (noexcept); delete the copy operations

    [[nodiscard]] std::size_t size() const { return size_; }
    [[nodiscard]] int* data() const { return data_; }

private:
    int* data_;
    std::size_t size_;
};
