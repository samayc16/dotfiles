from collections.abc import Callable
from functools import wraps


def count_calls(fn: Callable) -> Callable:
    return fn  # TODO: wrap fn, count calls in wrapper.calls, use @wraps


def retry(times: int) -> Callable[[Callable], Callable]:
    raise NotImplementedError("return a decorator")
