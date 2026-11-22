enum BankError: Error { case insufficientFunds }

struct Transaction {  // TODO: safe to send across tasks
    let amount: Int
    let memo: String
}

final class BankAccount {  // TODO: shared mutable state across tasks needs an actor
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
