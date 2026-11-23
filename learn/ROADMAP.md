# learn: where to start

Everything here works offline once `~/dotfiles/learn/fetch.sh` has run (it downloads
Exercism tracks, example projects and reference docs into `~/learn`).

```
learn                 dashboard: level, XP, streak, next up
learn list <track>    exercises with ★ (🔒 = pass earlier ones first; --all shows everything)
learn next [track]    open the next exercise in nvim
learn check           run the checks (inside an exercise)    learn hint / solution / giveup
learn docs [lang]     offline reference docs
```

In nvim everything is under `<leader>l`: `ll` pick · `lc` check · `lh` hint · `ln` next ·
`ls` solution · `lr` README · `ld` dashboard · `lD` docs. Exercises open as buffers (one tab each in the
buffer line) with the README on the right; checks run in a bottom panel. Neovim motions and
config drills are a separate game: `:Dojo`.

**Stars:** ★ pass · ★★ no hints · ★★★ no hints and first try (or golfed under par in the shell track).
Replay any time to improve. XP = stars × exercise XP; levels at 25·N² XP; a daily streak keeps you honest.

## The loop for every language

1. **Koans** (`<lang>-koans`): one modern feature per exercise. Small, fast, fun.
2. **Exercism concept exercises** (`<lang>`): the first part of each Exercism track teaches one concept each,
   with a proper introduction in the README.
3. **Exercism practice exercises**: classic problems with real test suites, ordered by difficulty.
4. **Reading quests** (`learn/projects/<lang>.md`): real code navigated with your LSP.

The nvim keys that matter at every step:

| when | keys |
|---|---|
| don't know what something is | `K` hover · `<leader>lD` docs |
| where is it defined / used | `grd` definition · `grr` references · `<C-o>` back · `gO` symbols |
| compiler/type errors | `]d` next diagnostic · `gra` code action (quick fixes, imports) · `<leader>q` list |
| rename safely | `grn` |
| run it | `<leader>rr` current file · `<leader>lc` exercise checks |
| why is it wrong | `<leader>db` breakpoint · `<leader>dc` start/continue · `<leader>di`/`<leader>do` step |

---

## C: start here

You already know some C if you've touched embedded code; the goal is *modern, safe* C.
Everything compiles as **C23** with AddressSanitizer + UBSan, so memory bugs are loud.

1. `learn next c-koans`: 12 koans: C23 basics → pointers → strings → structs → tagged unions →
   a growable vector with `realloc` → function pointers → bits → `typeof`/`_Generic` → file I/O → struct padding.
2. `learn next c`: Exercism C (Unity test framework; every test enabled; built as C23).
   Do hello-world → leap → difference-of-squares → grains, then whatever looks fun.
3. Reading: `learn/projects/c.md`: **kilo** (a text editor in 1,300 lines) then **chibicc** (a C compiler).
4. Docs: `learn docs c` (cppreference, C section). `man 3 printf` works offline too.

## C++: start here

Target is **C++26** (`-std=c++26`, Apple clang 21 + libc++). Think "C with ownership in the types".

1. `learn next cpp-koans`: 14 koans: `auto`/bindings/`std::format` → move semantics → smart pointers →
   lambdas → algorithms → ranges/views → custom formatters → `optional`/`variant`/`expected` →
   `string_view`/`span` → `enum class` → concepts → `constexpr` → `<=>` → C++26 pack indexing & `mdspan`.
2. `learn next cpp`: Exercism C++ (Catch2; CMake; built as C++26). Concept exercises first.
3. Reading: `learn/projects/cpp.md`: **argparse** (modern header-only API design) and **SPSCQueue** (atomics).
4. Docs: `learn docs cpp` (cppreference, offline). Use `<leader>th` (inlay hints) to see what `auto` deduced.

Not available in this libc++ yet: `<generator>`, `views::enumerate/chunk/slide/stride`. The koans avoid them.

## Rust: start here

**Rust 2024 edition**, std only, so it all works offline. From C/C++, think "RAII and move-by-default, with a
compiler that proves there are no dangling references or data races".

1. `learn next rust-koans`: 17 koans: ownership and moves → borrowing and slices → structs → enums and `match` →
   errors with `?` → traits and generics → `dyn` trait objects → iterators and closures → collections and UTF-8 →
   lifetimes → `Box`/`Rc`/`RefCell` → modules → let-else and let chains → threads, channels and `Arc<Mutex>` →
   const generics → `unsafe` and calling C → a boss: a calculator with variables. Each koan is a Cargo project:
   rust-analyzer just works, the checks are plain `#[test]`s you can read (and `cargo test`), and clippy's tips
   appear once you pass.
2. `learn next rust`: Exercism Rust (a Cargo crate per exercise; every test runs, the `#[ignore]`d ones too).
3. Docs: `learn docs rust`: The Book, the standard library and Rust by Example, installed by rustup (`rust-docs`).
4. In nvim: `K` on anything, `<leader>ce` explains an error code, `<leader>th` shows inferred types and elided
   lifetimes, `<leader>rn` runs a single test.

## Swift: start here

**Swift 6** language mode (strict concurrency on), so data races are compile errors.

1. `learn next swift-koans`: 13 koans: optionals → structs vs classes → enums with payloads → protocols →
   generics → closures → typed throws → `Result` → collections → property wrappers → `Codable` →
   async/await → actors.
2. `learn next swift`: Exercism Swift (each exercise is a Swift package; `swift test`).
3. Reading: `learn/projects/swift.md`: **swift-argument-parser**.
4. Docs: `learn docs swift`: *The Swift Programming Language* as Markdown (renders in nvim).
5. Apps: in an Xcode project folder run `:XcodebuildSetup`, then `<leader>X` for build/run/test/preview.

## SystemVerilog / Verilog: start here

1. `learn next systemverilog`: 22 exercises from AND gates through FSMs and FIFOs to assertions and a
   UVM-style class-based testbench. Each one is checked by a self-checking testbench on Verilator.
2. Reading: `learn/projects/sv.md`: **picorv32**, a full RISC-V CPU in one file. Simulate it with Icarus.
3. Docs: `learn docs sv`: the track's READMEs, the Verilator user guide, and Verilator's examples.
4. In nvim: slang-server gives real elaboration (`grd` across modules, widths on `K`); `<leader>vh` shows the
   hierarchy; `<leader>rr` simulates the current file.

## Python: start here

1. `learn next python-koans`: 15 koans: f-strings → comprehensions → lambdas → **dataclasses** →
   frozen/slots/`replace` → enums → `match` → generators → itertools/functools → decorators →
   context managers → generics (PEP 695)/Protocol/TypedDict → ExceptionGroup → pathlib/walrus → asyncio.
2. `learn next python`: Exercism Python (pytest, from `~/learn/.venv`).
3. Reading: `learn/projects/python.md`: **micrograd** (autograd in 150 lines) and **stamina** (a typed library).
4. Docs: `learn docs python` (the full Python docs, offline).

## Haskell: start here (from zero)

1. Read chapters 1–3 of *Learn You a Haskell*: `learn docs haskell` (Markdown, renders in nvim).
2. `learn next haskell-koans`: 24 koans at the Lambda Monastery, from expressions to a parser and a bank.
3. Keep `learn docs haskell` → *GHC base library* open for `Prelude`, `Data.List`, `Data.Maybe`.

## Shell (grep, rg, sed, awk): start here

`learn next shell`: 35 levels of on-call detective work at a fictional company: logs, CSVs and configs
with grep, ripgrep, cut/sort/uniq, sed and awk. Shorter solutions earn ★★★ (golf par).
`tldr <cmd>` has offline examples for any command (`fetch.sh` refreshes its cache).
