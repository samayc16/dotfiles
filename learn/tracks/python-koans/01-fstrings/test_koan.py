from harness import run
from koan import debug_expr, percent, receipt_line


def test_receipt_line_is_aligned():
    got = receipt_line("apple", 3, 1.5)
    assert got == "apple         3 x     1.50", f"got {got!r}"


def test_percent_has_one_decimal():
    assert percent(0.256) == "25.6%", f"got {percent(0.256)!r}"
    assert percent(1) == "100.0%"


def test_debug_form():
    assert debug_expr(42) == "x=42", f"got {debug_expr(42)!r}"


run(globals())
