"""Expose vendored Exercism tracks (~/learn/vendor/<lang>) through the shared interface.

Exercism content is MIT licensed and fetched by learn/fetch.sh; nothing is vendored
into the dotfiles repo. Concept exercises (which teach one feature each) come first,
then practice exercises ordered by difficulty.
"""

from __future__ import annotations

import json
import math
import os
import re
from pathlib import Path

from .model import Exercise, Track

LEARN_HOME = Path(os.environ.get("LEARN_HOME", Path.home() / "learn"))
VENDOR_DIR = LEARN_HOME / "vendor"

TRACKS = {
    "python": ("Python · Exercism", "python"),
    "c": ("C · Exercism", "c"),
    "cpp": ("C++ · Exercism", "cpp"),
    "swift": ("Swift · Exercism", "swift"),
    "rust": ("Rust · Exercism", "rust"),
}

SKIP_STATUS = {"deprecated", "wip"}


def _read_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return {}


def _title(slug: str) -> str:
    return " ".join(part.capitalize() for part in slug.split("-"))


def split_hints(text: str) -> tuple[str, ...]:
    """Turn .docs/hints.md into one hint per `## ` section."""
    sections = re.split(r"^## ", text, flags=re.MULTILINE)
    return tuple(f"## {s.strip()}" for s in sections[1:] if s.strip())


def _exercise(track: str, kind: str, entry: dict, root: Path) -> Exercise | None:
    ex_dir = root / "exercises" / kind / entry["slug"]
    meta = _read_json(ex_dir / ".meta" / "config.json")
    files = meta.get("files", {})
    solution = tuple(files.get("solution", []))
    if not ex_dir.is_dir() or not solution:
        return None
    raw_difficulty = int(entry.get("difficulty", 1))
    hints_md = ex_dir / ".docs" / "hints.md"
    return Exercise(
        track=track,
        slug=entry["slug"],
        title=str(entry.get("name") or _title(entry["slug"])),
        difficulty=1 if kind == "concept" else max(1, min(5, math.ceil(raw_difficulty / 2))),
        xp=15 if kind == "concept" else 5 + 3 * raw_difficulty,
        source_dir=ex_dir,
        files=solution,
        open=solution[0],
        concepts=tuple(entry.get("concepts") or entry.get("practices") or ()),
        hints=split_hints(hints_md.read_text()) if hints_md.is_file() else (),
        par=None,
        kind="exercism",
        language=TRACKS[track][1],
        extra={
            "tests": tuple(files.get("test", [])),
            "reference": tuple(files.get("example") or files.get("exemplar") or ()),
            "exercism_kind": kind,
        },
    )


def load_track(track: str) -> Track | None:
    root = VENDOR_DIR / track
    config = _read_json(root / "config.json")
    exercises_cfg = config.get("exercises", {})
    if not exercises_cfg:
        return None

    def active(entries: list[dict]) -> list[dict]:
        return [e for e in entries if e.get("status", "active") not in SKIP_STATUS]

    concept = active(exercises_cfg.get("concept") or [])
    practice = sorted(active(exercises_cfg.get("practice") or []), key=lambda e: int(e.get("difficulty", 1)))
    built = [_exercise(track, "concept", e, root) for e in concept]
    built += [_exercise(track, "practice", e, root) for e in practice]
    name, language = TRACKS[track]
    return Track(
        slug=track,
        name=name,
        language=language,
        description=f"Exercism's {language} track: concept lessons, then practice problems with real tests.",
        exercises=tuple(ex for ex in built if ex),
        kind="exercism",
    )


def load_all() -> list[Track]:
    tracks = (load_track(slug) for slug in TRACKS if (VENDOR_DIR / slug / "config.json").is_file())
    return [t for t in tracks if t and t.exercises]


def readme_text(exercise: Exercise) -> str:
    docs = exercise.source_dir / ".docs"
    parts = [f"# {exercise.title}\n"]
    for name in ("introduction.md", "instructions.md", "instructions.append.md"):
        path = docs / name
        if path.is_file():
            parts.append(path.read_text().strip() + "\n")
    parts.append(
        "\n---\n"
        f"Run the tests: `learn check` (or `<leader>lc` in nvim). Hints: `learn hint`.\n"
        f"Edit: {', '.join(exercise.files)}\n"
    )
    return "\n".join(parts)


def reference_files(exercise: Exercise) -> list[tuple[str, Path]]:
    """(display name, path) of the reference solution files."""
    return [(Path(rel).name, exercise.source_dir / rel) for rel in exercise.extra.get("reference", ())]


def test_command(exercise: Exercise, venv_python: Path) -> tuple[list[str], dict[str, str]]:
    """Command + extra env that runs the exercise's tests in its workspace."""
    lang = exercise.track
    if lang == "python":
        tests = list(exercise.extra.get("tests", ())) or ["."]
        python = str(venv_python) if venv_python.exists() else "python3"
        return [python, "-m", "pytest", "-q", "--no-header", "-p", "no:cacheprovider", *tests], {}
    if lang == "c":
        return ["sh", "-c", "make -s clean >/dev/null 2>&1; make -s test"], {}
    if lang == "cpp":
        script = (
            "cmake -S . -B build -DEXERCISM_RUN_ALL_TESTS=1 -DCMAKE_BUILD_TYPE=Debug "
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null && cmake --build build"
        )
        return ["sh", "-c", script], {}
    if lang == "swift":
        return ["swift", "test"], {"RUNALL": "true"}
    if lang == "rust":
        return ["cargo", "test", "--offline", "--", "--include-ignored"], {}  # Exercism #[ignore]s all but the first
    raise ValueError(f"no test command for track {lang}")
