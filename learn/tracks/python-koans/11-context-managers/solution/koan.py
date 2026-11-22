import os
import time
from collections.abc import Iterator
from contextlib import contextmanager


class Timer:
    def __enter__(self) -> "Timer":
        self._start = time.perf_counter()
        return self

    def __exit__(self, *exc_info) -> None:
        self.elapsed = time.perf_counter() - self._start


@contextmanager
def working_dir(path: str) -> Iterator[str]:
    previous = os.getcwd()
    os.chdir(path)
    try:
        yield path
    finally:
        os.chdir(previous)
