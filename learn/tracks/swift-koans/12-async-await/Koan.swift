func fetch(_ name: String, delay: Duration) async -> String {
    try? await Task.sleep(for: delay)
    return name.uppercased()
}

func fetchBoth(_ a: String, _ b: String, delay: Duration) async -> (String, String) {
    return (await fetch(a, delay: delay), await fetch(b, delay: delay))  // TODO: one after another!
}

func fetchAll(_ names: [String], delay: Duration) async -> [String] {
    var out: [String] = []
    for name in names { out.append(await fetch(name, delay: delay)) }
    return out
}
