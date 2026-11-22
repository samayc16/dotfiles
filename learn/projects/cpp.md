# Reading quests: C++

Modern, production-quality C++ small enough to read in a sitting. Projects live in
`~/learn/projects/cpp/`; each has `compile_commands.json` so clangd knows the flags.

Keys: `gO` symbols · `grd` definition · `grr` references · `K` hover (shows deduced types) ·
`<leader>th` inlay hints · `<C-o>` back · `[x` enclosing scope.

## argparse: a header-only argument parser (`cd ~/learn/projects/cpp/argparse && nvim include/argparse/argparse.hpp`)

- [ ] **Start from usage.** Open `samples/` (`-` opens the directory) and read one sample. Then `grd` on
      `add_argument` to land in the library.
- [ ] **Fluent API.** `Argument::help`, `default_value`, `required` all return `Argument&`. Find them with `gO`.
      Why does returning `*this` by reference make `.help(..).default_value(..)` chaining work?
- [ ] **Type erasure.** `grd` on `get<T>()` (around `template <typename T> T get() const`). Values are stored
      as `std::any`: find the `std::any_cast`. What happens when you ask for the wrong type?
- [ ] **Templates + concepts-era tricks.** Search (`<leader>sg`) for `enable_if` and `if constexpr`. Pick one and
      explain to yourself what it selects at compile time. How would a C++20 `requires` clause read instead?
- [ ] **Prove it.** In a scratch file write a tiny CLI using argparse (`#include <argparse/argparse.hpp>`),
      build: `clang++ -std=c++26 -Iinclude scratch.cpp -o scratch && ./scratch --help`.

## SPSCQueue: a lock-free queue in ~250 lines (`cd ~/learn/projects/cpp/SPSCQueue && nvim include/rigtorp/SPSCQueue.h`)

- [ ] **Read the header comment** at the top: what does single-producer single-consumer buy you?
- [ ] **Atomics.** `gO` → `try_emplace` and `front`. Every `load`/`store` names a memory order
      (`memory_order_acquire`, `release`, `relaxed`). `K` on each. Which pairs synchronise with which?
- [ ] **False sharing.** Find `alignas(kFalseSharingRange)`. Why put the read and write indices on different
      cache lines? (Hint: two cores hammering the same 64-byte line.)
- [ ] **Perfect forwarding.** `emplace(Args&&... args)` → `std::forward<Args>(args)...`. Why not just copy?
- [ ] **Prove it.** Build the tests (`cmake --build build && ./build/SPSCQueueTest`), then break the memory
      order (make an acquire `relaxed`) and think about why tests might still pass on ARM/x86 anyway.
