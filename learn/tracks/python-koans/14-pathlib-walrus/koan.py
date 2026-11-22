from collections.abc import Iterator
from pathlib import Path
from typing import IO


def count_lines(folder: Path, pattern: str = "*.txt") -> int:
    raise NotImplementedError


def longest_line(path: Path) -> str:
    raise NotImplementedError


def read_chunks(stream: IO[str], size: int) -> Iterator[str]:
    raise NotImplementedError("while (chunk := ...)")
