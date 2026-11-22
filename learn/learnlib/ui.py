"""Terminal styling: Monokai Pro truecolour, disabled by NO_COLOR or a non-TTY stdout."""

from __future__ import annotations

import os
import sys

PALETTE = {
    "red": (255, 97, 136),
    "orange": (252, 152, 103),
    "yellow": (255, 216, 102),
    "green": (169, 220, 118),
    "cyan": (120, 220, 232),
    "purple": (171, 157, 242),
    "gray": (114, 112, 114),
    "white": (252, 252, 250),
}


def color_enabled() -> bool:
    if os.environ.get("NO_COLOR"):
        return False
    if os.environ.get("LEARN_FORCE_COLOR"):
        return True
    return sys.stdout.isatty()


def paint(text: str, color: str, *, bold: bool = False) -> str:
    if not color_enabled():
        return text
    r, g, b = PALETTE[color]
    prefix = "\033[1m" if bold else ""
    return f"{prefix}\033[38;2;{r};{g};{b}m{text}\033[0m"


def bold(text: str) -> str:
    return f"\033[1m{text}\033[0m" if color_enabled() else text


def dim(text: str) -> str:
    return paint(text, "gray")


def stars(count: int, total: int = 3) -> str:
    filled = paint("★" * count, "yellow") if count else ""
    empty = dim("☆" * (total - count))
    return filled + empty


def bar(done: float, total: float, width: int = 24, color: str = "green") -> str:
    ratio = 0.0 if total <= 0 else max(0.0, min(1.0, done / total))
    full = round(ratio * width)
    return paint("█" * full, color) + dim("░" * (width - full))


def rule(width: int = 60) -> str:
    return dim("─" * width)


def banner(lines: list[str], color: str = "green") -> str:
    width = max(len(line) for line in lines) + 4
    top = paint("╭" + "─" * width + "╮", color)
    bottom = paint("╰" + "─" * width + "╯", color)
    body = [paint("│", color) + "  " + line.ljust(width - 2) + paint("│", color) for line in lines]
    return "\n".join([top, *body, bottom])


def info(msg: str) -> None:
    print(paint("›", "cyan") + " " + msg)


def warn(msg: str) -> None:
    print(paint("!", "orange", bold=True) + " " + msg, file=sys.stderr)


def error(msg: str) -> None:
    print(paint("✗", "red", bold=True) + " " + msg, file=sys.stderr)
