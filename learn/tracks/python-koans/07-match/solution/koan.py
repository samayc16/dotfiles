from dataclasses import dataclass


@dataclass
class Circle:
    radius: float


@dataclass
class Rect:
    w: float
    h: float


def describe(shape: object) -> str:
    match shape:
        case Circle(radius=r):
            return f"circle r={r}"
        case Rect(w, h) if w == h:
            return f"square {w}"
        case Rect(w, h):
            return f"rect {w}x{h}"
        case _:
            return "unknown"


def handle(command: str) -> str:
    match command.split():
        case ["go", direction]:
            return f"going {direction}"
        case ["take", *items] if items:
            return "taking " + ", ".join(items)
        case ["quit"] | ["exit"]:
            return "bye"
        case _:
            return "what?"


def on_event(event: dict) -> str:
    match event:
        case {"type": "click", "pos": (x, y)}:
            return f"click at {x},{y}"
        case {"type": "key", "key": str(key)}:
            return f"key {key}"
        case _:
            return "ignored"
