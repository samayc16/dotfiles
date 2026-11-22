let koan = KoanRun()


let groups = groupByInitial(["awk", "sed", "ag", "sort"])
koan.check(groups["a"] == ["awk", "ag"] && groups["s"]?.count == 2, "grouping")
koan.check(parseInts(["1", "x", "3"]) == [1, 3], "compactMap")
koan.check(frequencies(["a", "b", "a"]) == ["a": 2, "b": 1], "reduce(into:)")
koan.check(sumOfOddSquares([1, 2, 3, 4]) == 10, "filter/map/reduce")
koan.check(pairs(["x", "y", "z"], [1, 2]) == ["x=1", "y=2"], "zip stops at the shorter one")

koan.finish()
