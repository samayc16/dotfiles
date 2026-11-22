func byLengthThenAlpha(_ names: [String]) -> [String] {
    return names.sorted { ($0.count, $0) < ($1.count, $1) }
}

func makeIncrementer(step: Int) -> () -> Int {
    var total = 0
    return {
        total += step
        return total
    }
}

final class EventBus {
    private var handlers: [(String) -> Void] = []

    func on(_ handler: @escaping (String) -> Void) { handlers.append(handler) }

    func emit(_ event: String) {
        for handler in handlers { handler(event) }
    }
}
