from __future__ import annotations

from enum import Enum, IntEnum, StrEnum, auto


class Color(Enum):
    RED = auto()
    GREEN = auto()
    BLUE = auto()

    def complement(self) -> Color:
        pairs = {Color.RED: Color.GREEN, Color.GREEN: Color.RED}
        return pairs.get(self, self)


class Level(IntEnum):
    DEBUG = 10
    INFO = 20
    ERROR = 40


class Status(StrEnum):
    TODO = "todo"
    DONE = "done"
