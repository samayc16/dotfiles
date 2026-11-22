from __future__ import annotations

from dataclasses import dataclass, replace


@dataclass  # TODO: make it frozen and slotted
class Point:
    x: float
    y: float

    def moved(self, dx: float, dy: float) -> Point:
        self.x += dx  # TODO: don't mutate, return a copy
        self.y += dy
        return self


@dataclass
class Inventory:
    items: tuple[str, ...] = ()

    def added(self, item: str) -> Inventory:
        raise NotImplementedError("return a new Inventory")
