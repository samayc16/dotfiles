struct Address { let street: String }
struct User { let name: String; let address: Address? }

func greet(_ name: String?) -> String {
    return "Hello, \(name ?? "stranger")!"
}

func firstEven(_ numbers: [Int]) -> Int? {
    return numbers.first { $0 % 2 == 0 }
}

func parsePort(_ text: String) -> Int? {
    guard let port = Int(text), (1...65535).contains(port) else { return nil }
    return port
}

func streetLength(_ user: User?) -> Int? {
    return user?.address?.street.count
}
