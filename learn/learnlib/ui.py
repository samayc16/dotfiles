"""Terminal styling: Monokai Pro truecolour, disabled by NO_COLOR or a non-TTY stdout."""

from __future__ import annotations

import os
import re
import sys
import unicodedata

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


ANSI = re.compile(r"\x1b\[[0-9;]*m")


def _char_width(char: str) -> int:
    if unicodedata.category(char) in ("Mn", "Me", "Cf"):
        return 0
    return 2 if unicodedata.east_asian_width(char) in ("W", "F") else 1


def width(text: str) -> int:
    """Columns `text` takes in a terminal: colour codes take none, emoji take two."""
    return sum(_char_width(char) for char in ANSI.sub("", text))


def pad(text: str, columns: int) -> str:
    """Left-align (possibly coloured) text in `columns`; plain text that is too long gets an ellipsis.

    str.ljust can't do this: it counts colour codes as characters, so painted cells never line up."""
    shown = width(text)
    if shown <= columns:
        return text + " " * (columns - shown)
    if ANSI.search(text):
        return text
    cut = ""
    for char in text:
        if width(cut + char) > columns - 1:
            break
        cut += char
    return cut + "…" + " " * (columns - 1 - width(cut))


def banner(lines: list[str], color: str = "green") -> str:
    inner = max(width(line) for line in lines) + 4
    top = paint("╭" + "─" * inner + "╮", color)
    bottom = paint("╰" + "─" * inner + "╯", color)
    body = [paint("│", color) + "  " + pad(line, inner - 2) + paint("│", color) for line in lines]
    return "\n".join([top, *body, bottom])


def info(msg: str) -> None:
    print(paint("›", "cyan") + " " + msg)


def warn(msg: str) -> None:
    print(paint("!", "orange", bold=True) + " " + msg, file=sys.stderr)


def error(msg: str) -> None:
    print(paint("✗", "red", bold=True) + " " + msg, file=sys.stderr)
