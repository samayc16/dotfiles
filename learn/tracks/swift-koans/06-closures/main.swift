let koan = KoanRun()


koan.check(byLengthThenAlpha(["sed", "awk", "grep", "rg"]) == ["rg", "awk", "sed", "grep"], "sort by length then alpha")
let byThree = makeIncrementer(step: 3)
_ = byThree()
koan.check(byThree() == 6, "the closure remembers its running total")
let bus = EventBus()
var seen: [String] = []
bus.on { seen.append("a:" + $0) }
bus.on { seen.append("b:" + $0) }
bus.emit("save")
koan.check(seen == ["a:save", "b:save"], "every handler ran", "\(seen)")

koan.finish()
