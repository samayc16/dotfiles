import os
import time
from collections.abc import Iterator
from contextlib import contextmanager


class Timer:
    pass  # TODO: __enter__ / __exit__ storing self.elapsed (seconds)


@contextmanager
def working_dir(path: str) -> Iterator[str]:
    raise NotImplementedError
