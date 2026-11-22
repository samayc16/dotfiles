from collections.abc import Iterable, Iterator
from itertools import islice


def fib() -> Iterator[int]:
    """0, 1, 1, 2, 3, 5, ... forever."""
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b


def take[T](n: int, iterable: Iterable[T]) -> list[T]:
    return list(islice(iterable, n))


def chunked[T](iterable: Iterable[T], size: int) -> Iterator[list[T]]:
    chunk: list[T] = []
    for item in iterable:
        chunk.append(item)
        if len(chunk) == size:
            yield chunk
            chunk = []
    if chunk:
        yield chunk


def flatten_deep(nested: list) -> Iterator:
    for item in nested:
        if isinstance(item, list):
            yield from flatten_deep(item)
        else:
            yield item


def running_total(nums: Iterable[int]) -> Iterator[int]:
    total = 0
    for n in nums:
        total += n
        yield total
