from harness import run
from koan import HasArea, Movie, Square, Stack, first, make_movie, total_area


def test_stack():
    s: Stack[int] = Stack()
    assert not s and len(s) == 0
    s.push(1), s.push(2)
    assert s and len(s) == 2 and s.peek() == 2 and s.pop() == 2 and s.pop() == 1


def test_empty_stack_raises():
    try:
        Stack().pop()
    except IndexError:
        return
    raise AssertionError("pop() on an empty Stack should raise IndexError")


def test_first():
    assert first([3, 4]) == 3 and first([]) is None and first("hi") == "h"


def test_protocol_matches_structurally():
    assert isinstance(Square(2), HasArea), "HasArea must be a runtime_checkable Protocol"
    assert not isinstance("nope", HasArea)
    assert total_area([Square(2), Square(3)]) == 13


def test_typed_dict():
    assert make_movie("Alien", 1979) == {"title": "Alien", "year": 1979}
    assert Movie.__required_keys__ == frozenset({"title", "year"})


run(globals())
