@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    let range: ClosedRange<Value>

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = Self.clamp(wrappedValue, to: range)
    }

    var wrappedValue: Value {
        get { value }
        set { value = Self.clamp(newValue, to: range) }
    }

    private static func clamp(_ x: Value, to range: ClosedRange<Value>) -> Value {
        min(max(x, range.lowerBound), range.upperBound)
    }
}

struct Volume {
    @Clamped(0...10) var level: Int = 5
}
