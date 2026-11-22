protocol Describable {
    var summary: String { get }
}

extension Describable {
    func shout() -> String { summary.uppercased() + "!" }
}

struct Book: Describable {
    let title: String
    let author: String
    var summary: String { "\(title) by \(author)" }
}

extension Int {
    var isEven: Bool { self % 2 == 0 }
}
