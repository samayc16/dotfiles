func byLengthThenAlpha(_ names: [String]) -> [String] {
    return names
}

func makeIncrementer(step: Int) -> () -> Int {
    return { step }
}

final class EventBus {
    private var handlers: [(String) -> Void] = []

    func on(_ handler: (String) -> Void) { }  // TODO: store it (it must escape)

    func emit(_ event: String) {
        // TODO: call every handler
    }
}
