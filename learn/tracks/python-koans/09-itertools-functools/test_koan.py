from harness import run
from koan import fib_memo, group_by_first_letter, neighbour_diffs, prefix_sums, product, square


def test_group_by_first_letter():
    assert group_by_first_letter(["sed", "awk", "sort", "ag"]) == {"a": ["ag", "awk"], "s": ["sed", "sort"]}


def test_neighbour_diffs():
    assert neighbour_diffs([1, 4, 9, 16]) == [3, 5, 7]


def test_prefix_sums():
    assert prefix_sums([1, 2, 3, 4]) == [1, 3, 6, 10]


def test_product():
    assert product([2, 3, 7]) == 42 and product([]) == 1


def test_fib_memo_is_fast():
    assert hasattr(fib_memo, "cache_info"), "decorate fib_memo with @cache (without it fib_memo(80) takes centuries)"
    assert fib_memo(80) == 23416728348467685


def test_square():
    assert callable(square), "square should be a partial of pow"
    assert square(9) == 81


run(globals())
