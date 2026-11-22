let koan = KoanRun()


let book = Book(title: "Dune", author: "Herbert")
func describe(_ item: some Describable) -> String { item.summary }
koan.check(describe(book) == "Dune by Herbert", "Book is Describable")
koan.check(book.shout() == "DUNE BY HERBERT!", "default shout() from the extension")
koan.check(4.isEven && !7.isEven, "Int.isEven")

koan.finish()
