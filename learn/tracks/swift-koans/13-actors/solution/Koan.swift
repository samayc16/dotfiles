enum BankError: Error { case insufficientFunds }

struct Transaction: Sendable {
    let amount: Int
    let memo: String
}

actor BankAccount {
    private(set) var balance = 0
    private(set) var history: [Transaction] = []

    func deposit(_ transaction: Transaction) {
        balance += transaction.amount
        history.append(transaction)
    }

    func withdraw(_ amount: Int) throws(BankError) {
        guard amount <= balance else { throw .insufficientFunds }
        balance -= amount
    }
}
