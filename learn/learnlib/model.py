"""Immutable value objects shared by every track source."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path


@dataclass(frozen=True)
class Exercise:
    track: str
    slug: str
    title: str
    difficulty: int  # 1..5
    xp: int
    source_dir: Path  # where the exercise lives (repo or ~/learn/vendor)
    files: tuple[str, ...]  # learner-editable paths, relative to the workspace
    open: str  # the main file to edit
    concepts: tuple[str, ...] = ()
    hints: tuple[str, ...] = ()
    par: int | None = None
    kind: str = "format"  # "format" (shared format) | "exercism"
    language: str = ""
    extra: dict = field(default_factory=dict, compare=False, hash=False)

    @property
    def key(self) -> str:
        return f"{self.track}/{self.slug}"


@dataclass(frozen=True)
class Track:
    slug: str
    name: str
    language: str
    description: str
    exercises: tuple[Exercise, ...]
    kind: str = "format"

    def find(self, slug: str) -> Exercise | None:
        return next((ex for ex in self.exercises if ex.slug == slug), None)

    def index_of(self, slug: str) -> int:
        return next((i for i, ex in enumerate(self.exercises) if ex.slug == slug), -1)
