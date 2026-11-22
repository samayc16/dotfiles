"""Workspaces: ~/learn/workspace/<track>/<slug>, one per exercise.

Preparing a workspace copies the learner-editable files (never overwriting edits),
writes README.md, a `.learn.json` marker, and editor support files so the language
server understands the exercise (pyrightconfig.json, compile_flags.txt).
"""

from __future__ import annotations

import json
import os
import re
import shutil
from pathlib import Path

from . import exercism
from .model import Exercise

LEARN_HOME = Path(os.environ.get("LEARN_HOME", Path.home() / "learn"))
WORKSPACE_ROOT = LEARN_HOME / "workspace"
VENV_DIR = LEARN_HOME / ".venv"
MARKER = ".learn.json"

C_STD = "c23"
CXX_STD = "c++26"
IGNORE_DIRS = {".meta", ".docs", ".build", "build", ".git"}


def path_for(exercise: Exercise) -> Path:
    return WORKSPACE_ROOT / exercise.track / exercise.slug


def find_marker(start: Path) -> Path | None:
    """Walk up from `start` to the nearest workspace marker."""
    for directory in (start, *start.parents):
        candidate = directory / MARKER
        if candidate.is_file():
            return candidate
    return None


def read_marker(start: Path) -> str | None:
    marker = find_marker(start)
    if marker is None:
        return None
    try:
        data = json.loads(marker.read_text())
        return f"{data['track']}/{data['slug']}"
    except (OSError, ValueError, KeyError):
        return None


def _copy_new(src: Path, dst: Path) -> None:
    """Copy src -> dst unless dst exists (keeps the learner's edits)."""
    if dst.exists():
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def _write_if_missing(path: Path, text: str) -> None:
    if not path.exists():
        path.write_text(text)


def _ide_files(exercise: Exercise, ws: Path) -> None:
    language = exercise.language
    if language == "python":
        config = {"venvPath": str(LEARN_HOME), "venv": ".venv", "typeCheckingMode": "standard"}
        _write_if_missing(ws / "pyrightconfig.json", json.dumps(config, indent=2) + "\n")
    elif language == "c":
        flags = [f"-std={C_STD}", "-Wall", "-Wextra", "-I.", "-Itest-framework"]
        _write_if_missing(ws / "compile_flags.txt", "\n".join(flags) + "\n")
    elif language == "cpp":
        flags = [f"-std={CXX_STD}", "-Wall", "-Wextra", "-I.", "-Itest"]
        _write_if_missing(ws / "compile_flags.txt", "\n".join(flags) + "\n")


def _patch_exercism_tests(exercise: Exercise, ws: Path) -> None:
    """Run every test (Exercism ships most of them disabled) and use modern standards."""
    if exercise.track == "c":
        for test in exercise.extra.get("tests", ()):
            path = ws / test
            if path.is_file():
                path.write_text(re.sub(r"^\s*TEST_IGNORE\(\);.*\n", "", path.read_text(), flags=re.MULTILINE))
        makefile = ws / "makefile"
        if makefile.is_file():
            makefile.write_text(makefile.read_text().replace("-std=c99", f"-std={C_STD}"))
    elif exercise.track == "cpp":
        cmake = ws / "CMakeLists.txt"
        if cmake.is_file():
            cmake.write_text(re.sub(r"CXX_STANDARD\s+\d+", "CXX_STANDARD 26", cmake.read_text()))


def _prepare_exercism(exercise: Exercise, ws: Path, fresh: bool) -> None:
    for src in exercise.source_dir.rglob("*"):
        rel = src.relative_to(exercise.source_dir)
        if src.is_dir() or rel.parts[0] in IGNORE_DIRS:
            continue
        _copy_new(src, ws / rel)
    _write_if_missing(ws / "README.md", exercism.readme_text(exercise))
    if fresh:
        _patch_exercism_tests(exercise, ws)


def _prepare_format(exercise: Exercise, ws: Path) -> None:
    for rel in exercise.files:
        src = exercise.source_dir / rel
        if src.is_file():
            _copy_new(src, ws / rel)
        else:
            (ws / rel).parent.mkdir(parents=True, exist_ok=True)
            (ws / rel).touch(exist_ok=True)
    readme = exercise.source_dir / "README.md"
    if readme.is_file():
        _copy_new(readme, ws / "README.md")


def prepare(exercise: Exercise) -> Path:
    ws = path_for(exercise)
    fresh = not ws.exists()  # patch Exercism tests once; never touch the learner's later edits
    ws.mkdir(parents=True, exist_ok=True)
    if exercise.kind == "exercism":
        _prepare_exercism(exercise, ws, fresh)
    else:
        _prepare_format(exercise, ws)
    _ide_files(exercise, ws)
    marker = {"track": exercise.track, "slug": exercise.slug}
    (ws / MARKER).write_text(json.dumps(marker) + "\n")
    return ws


def remove(exercise: Exercise) -> bool:
    ws = path_for(exercise)
    if not ws.exists():
        return False
    if WORKSPACE_ROOT not in ws.resolve().parents:
        raise RuntimeError(f"refusing to delete outside {WORKSPACE_ROOT}: {ws}")
    shutil.rmtree(ws)
    return True
