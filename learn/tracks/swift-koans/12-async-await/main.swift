let koan = KoanRun()


let clock = ContinuousClock()
var both = ("", "")
let bothTime = await clock.measure { both = await fetchBoth("a", "b", delay: .milliseconds(200)) }
koan.check(both == ("A", "B"), "fetchBoth results")
koan.check(bothTime < .milliseconds(380), "fetchBoth runs concurrently", "took \(bothTime)")
var all: [String] = []
let allTime = await clock.measure { all = await fetchAll(["x", "y", "z", "w"], delay: .milliseconds(200)) }
koan.check(all == ["X", "Y", "Z", "W"], "fetchAll keeps input order", "\(all)")
koan.check(allTime < .milliseconds(500), "fetchAll runs concurrently", "took \(allTime)")

koan.finish()
