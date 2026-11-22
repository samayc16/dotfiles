from collections.abc import Callable
from functools import wraps


def count_calls(fn: Callable) -> Callable:
    @wraps(fn)
    def wrapper(*args, **kwargs):
        wrapper.calls += 1
        return fn(*args, **kwargs)

    wrapper.calls = 0
    return wrapper


def retry(times: int) -> Callable[[Callable], Callable]:
    def decorator(fn: Callable) -> Callable:
        @wraps(fn)
        def wrapper(*args, **kwargs):
            for attempt in range(1, times + 1):
                try:
                    return fn(*args, **kwargs)
                except Exception:
                    if attempt == times:
                        raise
            raise AssertionError("unreachable")

        return wrapper

    return decorator
