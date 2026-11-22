from collections.abc import Callable, Iterable


def sort_by_age_then_name(people: list[dict]) -> list[dict]:
    return people  # TODO: sorted(..., key=lambda ...)


def make_multiplier(n: int) -> Callable[[int], int]:
    raise NotImplementedError("return a lambda that remembers n")


def apply_all(funcs: Iterable[Callable[[int], int]], x: int) -> list[int]:
    raise NotImplementedError


def top_n_by[T](items: Iterable[T], n: int, key: Callable[[T], float]) -> list[T]:
    raise NotImplementedError
