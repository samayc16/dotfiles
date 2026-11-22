struct Address { let street: String }
struct User { let name: String; let address: Address? }

func greet(_ name: String?) -> String {
    return "Hello!"
}

func firstEven(_ numbers: [Int]) -> Int? {
    return numbers.first
}

func parsePort(_ text: String) -> Int? {
    return Int(text)  // TODO: also reject numbers outside 1...65535
}

func streetLength(_ user: User?) -> Int? {
    return nil
}
