# Reading quests: Swift

`~/learn/projects/swift/swift-argument-parser`, Apple's command-line parsing package, written
in modern Swift (property wrappers, protocols with defaults, generics, result builders). It was
built once by `learn/fetch.sh`, so sourcekit-lsp has an index and `grd` works across files.

Keys: `gO` symbols · `grd` definition · `grr` references · `K` hover (full types) · `gra` code actions.
Open it: `cd ~/learn/projects/swift/swift-argument-parser && nvim Examples/math/Math.swift`

- [ ] **Read an example first.** `Examples/math/Math.swift` defines a command tree. Find `@main`, `ParsableCommand`
      and the nested `subcommands`.
- [ ] **Property wrappers.** `grd` on `@Option`, `@Flag` and `@Argument` (they're in `Sources/ArgumentParser/Parsable Properties/`).
      Find `wrappedValue`: how does a struct field become a command-line option?
- [ ] **Protocols with default implementations.** `grd` on `ParsableCommand`, then find its `extension` that provides
      `main()`. Why can your command get a `main` without writing one?
- [ ] **Generics + constraints.** `K` on `Option` to read its generic signature (`Option<Value>`), then find the
      `where Value: ExpressibleByArgument` initialisers (`<leader>sg` "ExpressibleByArgument").
- [ ] **Errors.** `grr` on `ValidationError`: how do commands report bad input?
- [ ] **Prove it.** `swift run math add 1 2 3` in a terminal (`<leader>tt`), then add a `multiply` subcommand to
      `Math.swift` modelled on `add`, and run it.

> iOS/macOS apps: `:XcodebuildSetup` in a folder with an `.xcodeproj`, then `<leader>X` for build / run / test.
