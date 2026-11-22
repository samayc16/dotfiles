import Foundation

struct Todo: Equatable {  // TODO: Codable + CodingKeys (isDone <-> "is_done")
    let id: Int
    let title: String
    let isDone: Bool
    
}

func decodeTodos(_ json: String) throws -> [Todo] {
    return []
}

func roundTrip(_ todo: Todo) throws -> Todo {
    return todo  // TODO: encode to JSON Data, then decode it back
}
