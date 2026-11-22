import inspect

from harness import run
from koan import chunked, fib, flatten_deep, running_total, take


def test_fib_is_a_generator():
    assert inspect.isgeneratorfunction(fib), "use yield"
    assert take(8, fib()) == [0, 1, 1, 2, 3, 5, 8, 13]


def test_chunked():
    assert list(chunked(range(7), 3)) == [[0, 1, 2], [3, 4, 5], [6]]


def test_chunked_is_lazy():
    first = next(chunked(fib(), 2))  # fib() is infinite: only works if chunked is lazy
    assert first == [0, 1]


def test_flatten_deep():
    assert list(flatten_deep([1, [2, [3, [4]], 5]])) == [1, 2, 3, 4, 5]


def test_running_total():
    assert list(running_total([3, 1, 4, 1, 5])) == [3, 4, 8, 9, 14]


run(globals())
