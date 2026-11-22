from collections.abc import Iterator
from pathlib import Path
from typing import IO


def count_lines(folder: Path, pattern: str = "*.txt") -> int:
    return sum(len(path.read_text().splitlines()) for path in folder.glob(pattern))


def longest_line(path: Path) -> str:
    return max(path.read_text().splitlines(), key=len, default="")


def read_chunks(stream: IO[str], size: int) -> Iterator[str]:
    while chunk := stream.read(size):
        yield chunk
