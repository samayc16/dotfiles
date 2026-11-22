let koan = KoanRun()


koan.check((try? parseAge("42")) == 42, "valid age")
koan.check(ageOrNil("x") == nil && ageOrNil("7") == 7, "try? turns errors into nil")
koan.check(message(for: "") == "please enter an age", "empty", message(for: ""))
koan.check(message(for: "abc") == "'abc' is not a number", "not a number", message(for: "abc"))
koan.check(message(for: "200") == "200 is out of range" && message(for: "30") == "age 30", "range")

koan.finish()
