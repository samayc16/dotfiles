let koan = KoanRun()


koan.check(greet("Ada") == "Hello, Ada!", "greet with a name", greet("Ada"))
koan.check(greet(nil) == "Hello, stranger!", "greet nil", greet(nil))
koan.check(firstEven([1, 3, 4, 6]) == 4 && firstEven([1, 3]) == nil, "firstEven")
koan.check(parsePort("8080") == 8080 && parsePort("70000") == nil && parsePort("http") == nil, "parsePort")
koan.check(streetLength(User(name: "a", address: Address(street: "Main"))) == 4, "streetLength found")
koan.check(streetLength(User(name: "b", address: nil)) == nil && streetLength(nil) == nil, "streetLength nil chain")

koan.finish()
