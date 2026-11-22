from collections.abc import Callable, Iterable


def sort_by_age_then_name(people: list[dict]) -> list[dict]:
    return sorted(people, key=lambda p: (p["age"], p["name"]))


def make_multiplier(n: int) -> Callable[[int], int]:
    return lambda x: x * n


def apply_all(funcs: Iterable[Callable[[int], int]], x: int) -> list[int]:
    return [f(x) for f in funcs]


def top_n_by[T](items: Iterable[T], n: int, key: Callable[[T], float]) -> list[T]:
    return sorted(items, key=key, reverse=True)[:n]
