import dataclasses

from harness import run
from koan import Inventory, Point


def test_point_is_frozen():
    p = Point(1, 2)
    try:
        p.x = 5
    except dataclasses.FrozenInstanceError:
        return
    raise AssertionError("assigning to a frozen dataclass should raise FrozenInstanceError")


def test_point_uses_slots():
    assert not hasattr(Point(1, 2), "__dict__"), "slots=True removes the per-instance __dict__"


def test_moved_returns_new_point():
    p = Point(1, 2)
    q = p.moved(2, 3)
    assert q == Point(3, 5) and p == Point(1, 2), f"p={p}, q={q}"


def test_points_are_hashable():
    assert len({Point(0, 0), Point(0, 0), Point(1, 1)}) == 2


def test_inventory_added_is_immutable():
    empty = Inventory()
    one = empty.added("sword")
    two = one.added("shield")
    assert empty.items == () and one.items == ("sword",) and two.items == ("sword", "shield")


run(globals())
