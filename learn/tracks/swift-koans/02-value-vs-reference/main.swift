let koan = KoanRun()


var a = Counter()
a.increment()
var b = a
b.increment()
b.increment()
koan.check(a.count == 1 && b.count == 3, "struct copies are independent", "a=\(a.count) b=\(b.count)")
let x = Account(balance: 10)
let y = x
y.balance += 5
koan.check(x.balance == 15 && x === y, "class references share one instance")

koan.finish()
