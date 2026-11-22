func fetch(_ name: String, delay: Duration) async -> String {
    try? await Task.sleep(for: delay)
    return name.uppercased()
}

func fetchBoth(_ a: String, _ b: String, delay: Duration) async -> (String, String) {
    async let first = fetch(a, delay: delay)
    async let second = fetch(b, delay: delay)
    return await (first, second)
}

func fetchAll(_ names: [String], delay: Duration) async -> [String] {
    await withTaskGroup(of: (Int, String).self) { group in
        for (index, name) in names.enumerated() {
            group.addTask { (index, await fetch(name, delay: delay)) }
        }
        var results: [(Int, String)] = []
        for await result in group {
            results.append(result)
        }
        return results.sorted { $0.0 < $1.0 }.map(\.1)
    }
}
