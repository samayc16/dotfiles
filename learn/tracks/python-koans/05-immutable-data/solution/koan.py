from __future__ import annotations

from dataclasses import dataclass, replace


@dataclass(frozen=True, slots=True)
class Point:
    x: float
    y: float

    def moved(self, dx: float, dy: float) -> Point:
        return replace(self, x=self.x + dx, y=self.y + dy)


@dataclass(frozen=True)
class Inventory:
    items: tuple[str, ...] = ()

    def added(self, item: str) -> Inventory:
        return replace(self, items=(*self.items, item))
