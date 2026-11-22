from collections.abc import Iterable, Sequence
from typing import Protocol, TypedDict, runtime_checkable


class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        if not self._items:
            raise IndexError("pop from empty Stack")
        return self._items.pop()

    def peek(self) -> T:
        if not self._items:
            raise IndexError("peek at empty Stack")
        return self._items[-1]

    def __len__(self) -> int:
        return len(self._items)

    def __bool__(self) -> bool:
        return bool(self._items)


def first[T](items: Sequence[T]) -> T | None:
    return items[0] if items else None


@runtime_checkable
class HasArea(Protocol):
    def area(self) -> float: ...


class Square:
    def __init__(self, side: float) -> None:
        self.side = side

    def area(self) -> float:
        return self.side**2


def total_area(shapes: Iterable[HasArea]) -> float:
    return sum(shape.area() for shape in shapes)


class Movie(TypedDict):
    title: str
    year: int


def make_movie(title: str, year: int) -> Movie:
    return {"title": title, "year": year}
