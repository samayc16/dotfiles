struct Counter {
    var count = 0
    mutating func increment() { count += 1 }
}

final class Account {
    var balance: Int
    init(balance: Int) { self.balance = balance }
}
