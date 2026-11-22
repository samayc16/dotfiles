struct Stack<Element> {
    // TODO: storage, push, pop (returns nil when empty), peek, isEmpty, count
}

func allEqual<C: Collection>(_ collection: C) -> Bool where C.Element: Equatable {
    return false
}

func largest<T: Comparable>(_ values: [T]) -> T? {
    return values.first
}
