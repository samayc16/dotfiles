final class Counter {  // TODO: should copies be independent? make it a struct
    var count = 0
    func increment() { count += 1 }
}

final class Account {
    var balance: Int
    init(balance: Int) { self.balance = balance }
}
