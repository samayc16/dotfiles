import Foundation

enum Shape {
    case circle(radius: Double)
    case rect(width: Double, height: Double)
    case triangle(base: Double, height: Double)

    var area: Double {
        switch self {
        case .circle(let radius): return Double.pi * radius * radius
        case let .rect(width, height): return width * height
        case let .triangle(base, height): return base * height / 2
        }
    }
}

enum Command: Equatable {
    case go(String)
    case wait

    init?(parsing text: String) {
        let parts = text.split(separator: " ").map(String.init)
        switch parts.count {
        case 2 where parts[0] == "go": self = .go(parts[1])
        case 1 where parts[0] == "wait": self = .wait
        default: return nil
        }
    }
}

enum Suit: CaseIterable { case hearts, diamonds, clubs, spades }
