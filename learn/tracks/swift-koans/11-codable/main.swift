let koan = KoanRun()


import Foundation

let json = #"[{"id": 1, "title": "learn awk", "is_done": false}, {"id": 2, "title": "learn sed", "is_done": true}]"#
let todos = (try? decodeTodos(json)) ?? []
koan.check(todos.count == 2 && todos[1].isDone && todos[0].title == "learn awk", "decode with snake_case key")
let original = Todo(id: 9, title: "ship it", isDone: true)
koan.check((try? roundTrip(original)) == original, "encode -> decode round trip")
let encoded = (try? JSONEncoder().encode(original)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
koan.check(encoded.contains("\"is_done\""), "encoded JSON uses is_done", encoded)

koan.finish()
