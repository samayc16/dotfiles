// Tiny koan harness: koan.check(condition, label) prints ✓/✗; koan.finish() exits non-zero on failure.
import Foundation

final class KoanRun {
    private var total = 0
    private var failed = 0
    private let useColor = ProcessInfo.processInfo.environment["NO_COLOR"] == nil

    private func paint(_ text: String, _ rgb: (Int, Int, Int)) -> String {
        useColor ? "\u{1B}[38;2;\(rgb.0);\(rgb.1);\(rgb.2)m\(text)\u{1B}[0m" : text
    }

    func check(_ condition: @autoclosure () throws -> Bool, _ label: String, _ detail: @autoclosure () -> String = "") {
        total += 1
        var passed = false
        var note = ""
        do {
            passed = try condition()
            if !passed { note = detail() }
        } catch {
            note = "threw \(error)"
        }
        if passed {
            print("  \(paint("✓", (169, 220, 118))) \(label)")
        } else {
            failed += 1
            print("  \(paint("✗", (255, 97, 136))) \(label)\(note.isEmpty ? "" : " — \(note)")")
        }
    }

    func finish() -> Never {
        print("\n  \(total - failed)/\(total) checks passing")
        exit(failed == 0 ? 0 : 1)
    }
}
