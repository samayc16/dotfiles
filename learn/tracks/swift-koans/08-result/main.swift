let koan = KoanRun()


koan.check(divide(10, 2) == .success(5) && divide(1, 0) == .failure(.divisionByZero), "divide")
koan.check(divideTwice(100, by: 5, then: 2) == .success(10), "chained")
koan.check(divideTwice(100, by: 0, then: 2) == .failure(.divisionByZero), "error short-circuits")
koan.check(describe(.success(3)) == "ok 3" && describe(.failure(.divisionByZero)) == "error: division by zero", "describe")
koan.check(((try? divide(9, 3).get()) ?? 0) == 3, "get() rethrows")

koan.finish()
