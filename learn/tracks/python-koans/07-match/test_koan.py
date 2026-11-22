from harness import run
from koan import Circle, Rect, describe, handle, on_event


def test_describe_shapes():
    assert describe(Circle(2)) == "circle r=2"
    assert describe(Rect(3, 3)) == "square 3"
    assert describe(Rect(2, 5)) == "rect 2x5"
    assert describe("triangle") == "unknown"


def test_handle_commands():
    assert handle("go north") == "going north"
    assert handle("take sword shield") == "taking sword, shield"
    assert handle("quit") == "bye" and handle("exit") == "bye"
    assert handle("take") == "what?" and handle("dance wildly now") == "what?"


def test_events():
    assert on_event({"type": "click", "pos": (3, 4)}) == "click at 3,4"
    assert on_event({"type": "key", "key": "q", "mods": []}) == "key q"
    assert on_event({"type": "scroll"}) == "ignored"


run(globals())
