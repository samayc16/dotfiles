enum AgeError: Error, Equatable {
    case empty
    case notANumber(String)
    case outOfRange(Int)
}

func parseAge(_ text: String) throws(AgeError) -> Int {
    guard !text.isEmpty else { throw .empty }
    guard let age = Int(text) else { throw .notANumber(text) }
    guard (0...150).contains(age) else { throw .outOfRange(age) }
    return age
}

func ageOrNil(_ text: String) -> Int? {
    return try? parseAge(text)
}

func message(for text: String) -> String {
    do {
        return "age \(try parseAge(text))"
    } catch {
        switch error {
        case .empty: return "please enter an age"
        case .notANumber(let raw): return "'\(raw)' is not a number"
        case .outOfRange(let n): return "\(n) is out of range"
        }
    }
}
