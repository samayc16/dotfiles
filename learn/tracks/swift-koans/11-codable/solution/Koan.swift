import Foundation

struct Todo: Codable, Equatable {
    let id: Int
    let title: String
    let isDone: Bool
    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
    }
}

func decodeTodos(_ json: String) throws -> [Todo] {
    try JSONDecoder().decode([Todo].self, from: Data(json.utf8))
}

func roundTrip(_ todo: Todo) throws -> Todo {
    let data = try JSONEncoder().encode(todo)
    return try JSONDecoder().decode(Todo.self, from: data)
}
