from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Item:
    name: str
    price: float
    tags: list[str] = field(default_factory=list)

    def __post_init__(self) -> None:
        if self.price < 0:
            raise ValueError(f"price must be >= 0, got {self.price}")


@dataclass(order=True)
class Version:
    major: int
    minor: int
    patch: int

    @classmethod
    def parse(cls, text: str) -> Version:
        major, minor, patch = (int(part) for part in text.split("."))
        return cls(major, minor, patch)
