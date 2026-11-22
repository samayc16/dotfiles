enum AgeError: Error, Equatable {
    case empty
    case notANumber(String)
    case outOfRange(Int)
}

func parseAge(_ text: String) throws -> Int {  // TODO: typed throws(AgeError), validate
    return Int(text) ?? 0
}

func ageOrNil(_ text: String) -> Int? {
    return nil
}

func message(for text: String) -> String {
    return "?"
}
