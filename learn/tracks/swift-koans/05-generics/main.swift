let koan = KoanRun()


var stack = Stack<String>()
koan.check(stack.isEmpty && stack.pop() == nil, "empty stack")
stack.push("a")
stack.push("b")
koan.check(stack.count == 2 && stack.peek() == "b" && stack.pop() == "b" && stack.pop() == "a", "LIFO order")
koan.check(allEqual([3, 3, 3]) && !allEqual("aab") && allEqual([Int]()), "allEqual")
koan.check(largest([3, 9, 2]) == 9 && largest(["vim", "awk"]) == "vim" && largest([Int]()) == nil, "largest")

koan.finish()
