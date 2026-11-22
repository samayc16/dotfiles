from collections.abc import Iterable, Iterator
from itertools import islice


def fib() -> Iterator[int]:
    """0, 1, 1, 2, 3, 5, ... forever."""
    raise NotImplementedError


def take[T](n: int, iterable: Iterable[T]) -> list[T]:
    raise NotImplementedError


def chunked[T](iterable: Iterable[T], size: int) -> Iterator[list[T]]:
    raise NotImplementedError


def flatten_deep(nested: list) -> Iterator:
    raise NotImplementedError


def running_total(nums: Iterable[int]) -> Iterator[int]:
    raise NotImplementedError
