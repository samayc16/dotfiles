struct Stack<Element> {
    private var items: [Element] = []

    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop() -> Element? { items.popLast() }
    func peek() -> Element? { items.last }
    var isEmpty: Bool { items.isEmpty }
    var count: Int { items.count }
}

func allEqual<C: Collection>(_ collection: C) -> Bool where C.Element: Equatable {
    guard let first = collection.first else { return true }
    return collection.allSatisfy { $0 == first }
}

func largest<T: Comparable>(_ values: [T]) -> T? {
    return values.max()
}
