let koan = KoanRun()


let account = BankAccount()
await withTaskGroup(of: Void.self) { group in
    for i in 0..<1000 {
        group.addTask { await account.deposit(Transaction(amount: 1, memo: "#\(i)")) }
    }
}
let balance = await account.balance
koan.check(balance == 1000, "1,000 concurrent deposits add up", "balance=\(balance)")
let historyCount = await account.history.count
koan.check(historyCount == 1000, "history recorded every transaction")
var refused = false
do { try await account.withdraw(5000) } catch { refused = true }
koan.check(refused, "overdraft refused")

koan.finish()
