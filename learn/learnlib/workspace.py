"""Workspaces: ~/learn/workspace/<track>/<slug>, one per exercise.

Preparing a workspace copies the learner-editable files (never overwriting edits),
refreshes read-only support files (exercise.json "support": a Cargo.toml, tests), writes
README.md, a `.learn.json` marker, and editor support files so the language server
understands the exercise (pyrightconfig.json, compile_flags.txt).
"""

from __future__ import annotations

import glob
import json
import os
import re
import shutil
from pathlib import Path
from typing import List, Tuple

from . import exercism
from .model import Exercise

LEARN_HOME = Path(os.environ.get("LEARN_HOME", Path.home() / "learn"))
WORKSPACE_ROOT = LEARN_HOME / "workspace"
VENV_DIR = LEARN_HOME / ".venv"
MARKER = ".learn.json"



def default_swap_dirs() -> Tuple[Path, ...]:
    """Where Neovim keeps swap files ('directory' default: stdpath("state")/swap//)."""
    state = os.environ.get("XDG_STATE_HOME") or str(Path.home() / ".local" / "state")
    return (Path(state) / (os.environ.get("NVIM_APPNAME") or "nvim") / "swap",)


SWAP_DIRS = default_swap_dirs()
# Vim/Neovim swap file, block 0 (memline.c `struct block0`): b0_pid at bytes 24-27 (LSB first);
# b0_dirty, the last byte of the 900-byte b0_fname that starts at 108, is 0x55 while modified.
SWAP_PID = slice(24, 28)
SWAP_DIRTY_AT = 108 + 900 - 1
SWAP_DIRTY = 0x55

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


def _refresh(src: Path, dst: Path) -> None:
    """Make dst a copy of src, writing only on change (an untouched mtime keeps language
    servers from reloading a project file on every `learn check`)."""
    data = src.read_bytes()
    if dst.is_file() and dst.read_bytes() == data:
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(data)


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
    (ws / "README.md").write_text(exercism.readme_text(exercise))  # instructions, not learner code: keep current
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
    # Read-only project files (a Cargo.toml, the tests): kept current, never opened for editing.
    for rel in exercise.extra.get("support", ()):
        src = exercise.source_dir / rel
        if src.is_file():
            _refresh(src, ws / rel)
    readme = exercise.source_dir / "README.md"
    if readme.is_file():
        shutil.copyfile(readme, ws / "README.md")  # instructions, not learner code: keep current


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


def _swap_files(path: Path) -> List[Path]:
    """Swap files an editor may hold for `path`: Neovim's %-named ones, and Vim's .name.swp beside it."""
    found = list(path.parent.glob(glob.escape(f".{path.name}") + ".sw?"))
    for name in {str(path), str(path.resolve())}:
        encoded = glob.escape(name.replace(os.sep, "%"))
        for directory in SWAP_DIRS:
            found.extend(directory.glob(encoded + ".sw?"))
    return found


def _alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except PermissionError:
        return True
    except OSError:
        return False
    return True


def _modified_in_running_editor(swap: Path) -> bool:
    try:
        with swap.open("rb") as fh:
            block = fh.read(SWAP_DIRTY_AT + 1)
    except OSError:
        return False
    if len(block) <= SWAP_DIRTY_AT or block[:2] != b"b0" or block[SWAP_DIRTY_AT] != SWAP_DIRTY:
        return False
    pid = int.from_bytes(block[SWAP_PID], "little")
    return pid > 0 and _alive(pid)  # a dead pid is a crashed session: `nvim -r` territory, not ours


def unsaved_files(exercise: Exercise, ws: Path) -> List[str]:
    """Learner files that a running Vim/Neovim has modified but not saved: `learn check` can't see those."""
    return [rel for rel in exercise.files if any(_modified_in_running_editor(s) for s in _swap_files(ws / rel))]


def untouched_files(exercise: Exercise, ws: Path) -> List[str]:
    """Learner files still exactly as the starter was copied in."""
    untouched = []
    for rel in exercise.files:
        mine, starter = ws / rel, exercise.source_dir / rel
        try:
            if starter.is_file():
                same = mine.read_bytes() == starter.read_bytes()
            else:
                same = not mine.exists() or mine.stat().st_size == 0
        except OSError:
            same = False
        if same:
            untouched.append(rel)
    return untouched


def remove(exercise: Exercise) -> bool:
    ws = path_for(exercise)
    if not ws.exists():
        return False
    if WORKSPACE_ROOT not in ws.resolve().parents:
        raise RuntimeError(f"refusing to delete outside {WORKSPACE_ROOT}: {ws}")
    shutil.rmtree(ws)
    return True
