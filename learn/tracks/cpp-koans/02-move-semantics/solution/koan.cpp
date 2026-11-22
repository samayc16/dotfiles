#include <cstddef>
#include <utility>

class Buffer {
public:
    explicit Buffer(std::size_t size) : data_{new int[size]{}}, size_{size} {}
    ~Buffer() { delete[] data_; }

    Buffer(const Buffer&) = delete;
    Buffer& operator=(const Buffer&) = delete;

    Buffer(Buffer&& other) noexcept
        : data_{std::exchange(other.data_, nullptr)}, size_{std::exchange(other.size_, 0)} {}

    Buffer& operator=(Buffer&& other) noexcept {
        if (this != &other) {
            delete[] data_;
            data_ = std::exchange(other.data_, nullptr);
            size_ = std::exchange(other.size_, 0);
        }
        return *this;
    }

    [[nodiscard]] std::size_t size() const { return size_; }
    [[nodiscard]] int* data() const { return data_; }

private:
    int* data_;
    std::size_t size_;
};
