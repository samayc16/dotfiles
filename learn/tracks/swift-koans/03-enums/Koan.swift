import Foundation

enum Shape {
    case circle(radius: Double)
    case rect(width: Double, height: Double)
    case triangle(base: Double, height: Double)

    var area: Double {
        return 0
    }
}

enum Command: Equatable {
    case go(String)
    case wait

    init?(parsing text: String) {
        return nil
    }
}

enum Suit { case hearts, diamonds, clubs, spades }  // TODO: make every case listable
