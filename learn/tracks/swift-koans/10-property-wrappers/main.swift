let koan = KoanRun()


var volume = Volume()
koan.check(volume.level == 5, "starts at 5")
volume.level = 42
koan.check(volume.level == 10, "clamped to the upper bound", "level=\(volume.level)")
volume.level = -3
koan.check(volume.level == 0, "clamped to the lower bound", "level=\(volume.level)")

koan.finish()
