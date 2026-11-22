from collections.abc import Iterable, Sequence
from typing import Protocol, TypedDict, runtime_checkable


class Stack[T]:
    pass  # TODO: push, pop, peek, __len__, __bool__ (pop/peek on empty raise IndexError)


def first[T](items: Sequence[T]) -> T | None:
    raise NotImplementedError


class HasArea:  # TODO: a runtime_checkable Protocol with area() -> float
    pass


class Square:
    def __init__(self, side: float) -> None:
        self.side = side

    def area(self) -> float:
        return self.side**2


def total_area(shapes: Iterable[HasArea]) -> float:
    raise NotImplementedError


class Movie:  # TODO: TypedDict with title: str and year: int
    pass


def make_movie(title: str, year: int) -> Movie:
    raise NotImplementedError
