"""Stars, XP and levels.

Stars:  ★ pass · ★★ no hints used · ★★★ no hints AND (within par, or first-try pass when
the exercise has no par). Giving up caps an exercise at ★. Best result is kept.
Levels: level N starts at 25·N² XP.
"""

from __future__ import annotations

import math
import re
from pathlib import Path

TITLES = (
    "Novice",
    "Apprentice",
    "Tinkerer",
    "Journeyman",
    "Adept",
    "Specialist",
    "Expert",
    "Veteran",
    "Master",
    "Grandmaster",
    "Wizard",
    "Legend",
)

COMMENT_PREFIXES = ("#", "//", "--", ";")


def solution_length(path: Path) -> int:
    """Characters of real content: comment and blank lines dropped, each line trimmed."""
    try:
        lines = path.read_text().splitlines()
    except OSError:
        return 10**9
    kept = (line.strip() for line in lines)
    return sum(len(line) for line in kept if line and not line.startswith(COMMENT_PREFIXES))


def stars_for(*, hints_used: int, gave_up: bool, attempts: int, par: int | None, length: int | None) -> int:
    if gave_up:
        return 1
    if hints_used > 0:
        return 1
    if par is not None:
        return 3 if length is not None and length <= par else 2
    return 3 if attempts <= 1 else 2


def level_for(xp: int) -> int:
    return max(1, math.isqrt(max(0, xp) // 25) + 1)


def level_bounds(level: int) -> tuple[int, int]:
    return 25 * (level - 1) ** 2, 25 * level**2


def title_for(level: int) -> str:
    return TITLES[min(level - 1, len(TITLES) - 1)]


def strip_ansi(text: str) -> str:
    return re.sub(r"\x1b\[[0-9;]*m", "", text)
