from harness import run
from koan import Color, Level, Status


def test_color_members():
    assert [c.name for c in Color] == ["RED", "GREEN", "BLUE"]


def test_complement():
    assert Color.RED.complement() is Color.GREEN
    assert Color.BLUE.complement() is Color.BLUE


def test_levels_compare_with_ints():
    assert Level.ERROR > Level.INFO > 15


def test_status_is_a_string():
    assert Status("done") is Status.DONE
    assert f"{Status.TODO}" == "todo" and Status.TODO.upper() == "TODO"


run(globals())
