protocol Describable {
    var summary: String { get }
}

// TODO: extension Describable with a default shout() -> String (summary uppercased + "!")

struct Book {  // TODO: conform to Describable: summary = "<title> by <author>"
    let title: String
    let author: String
    
}

// TODO: extension Int { var isEven: Bool }
