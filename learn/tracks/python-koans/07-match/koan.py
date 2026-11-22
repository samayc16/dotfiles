from dataclasses import dataclass


@dataclass
class Circle:
    radius: float


@dataclass
class Rect:
    w: float
    h: float


def describe(shape: object) -> str:
    raise NotImplementedError("match shape: case Circle(radius=r): ...")


def handle(command: str) -> str:
    raise NotImplementedError("match command.split(): ...")


def on_event(event: dict) -> str:
    raise NotImplementedError("mapping patterns: case {'type': 'click', 'pos': (x, y)}")
