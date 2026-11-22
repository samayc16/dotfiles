let koan = KoanRun()


koan.check(abs(Shape.circle(radius: 1).area - Double.pi) < 1e-9, "circle area")
koan.check(Shape.rect(width: 2, height: 3).area == 6 && Shape.triangle(base: 4, height: 5).area == 10, "rect/triangle area")
koan.check(Command(parsing: "go north") == .go("north") && Command(parsing: "wait") == .wait, "parse commands")
koan.check(Command(parsing: "dance") == nil, "unknown command is nil")
koan.check(Suit.allCases.count == 4, "CaseIterable")

koan.finish()
