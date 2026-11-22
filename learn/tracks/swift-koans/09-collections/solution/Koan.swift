func groupByInitial(_ words: [String]) -> [Character: [String]] {
    Dictionary(grouping: words) { $0.first ?? " " }
}

func parseInts(_ texts: [String]) -> [Int] {
    texts.compactMap { Int($0) }
}

func frequencies(_ words: [String]) -> [String: Int] {
    words.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
}

func sumOfOddSquares(_ numbers: [Int]) -> Int {
    numbers.filter { $0 % 2 != 0 }.map { $0 * $0 }.reduce(0, +)
}

func pairs(_ keys: [String], _ values: [Int]) -> [String] {
    zip(keys, values).map { "\($0)=\($1)" }
}
