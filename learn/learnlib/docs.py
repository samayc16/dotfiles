"""Offline reference docs (fetched by learn/fetch.sh into ~/learn/docs)."""

from __future__ import annotations

import os
import platform
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from .tracks import TRACKS_DIR

LEARN_HOME = Path(os.environ.get("LEARN_HOME", Path.home() / "learn"))
DOCS_DIR = LEARN_HOME / "docs"


@dataclass(frozen=True)
class DocEntry:
    title: str
    path: Path
    kind: str  # "html" opens in a browser; "text" is Markdown/rST read in nvim

    @property
    def exists(self) -> bool:
        return self.path.exists()


def _first(pattern: str) -> Path:
    """First match of a glob under DOCS_DIR, or the unexpanded path (reported as missing)."""
    matches = sorted(DOCS_DIR.glob(pattern))
    return matches[0] if matches else DOCS_DIR / pattern


def _verilator_examples() -> Path:
    candidates = [Path("/usr/share/verilator/examples"), Path("/usr/local/share/verilator/examples")]
    brew = shutil.which("brew")
    if brew:
        try:
            prefix = subprocess.run(
                [brew, "--prefix", "verilator"], capture_output=True, text=True, timeout=10
            ).stdout.strip()
            candidates.insert(0, Path(prefix) / "share/verilator/examples")
        except (OSError, subprocess.SubprocessError):
            pass
    return next((c for c in candidates if c.exists()), candidates[0])


def registry() -> dict[str, list[DocEntry]]:
    return {
        "c": [DocEntry("cppreference: C", DOCS_DIR / "cppreference/reference/en/c.html", "html")],
        "cpp": [DocEntry("cppreference: C++", DOCS_DIR / "cppreference/reference/en/cpp.html", "html")],
        "python": [DocEntry("Python docs", _first("python/python-*-docs-html/index.html"), "html")],
        "haskell": [
            DocEntry("Learn You a Haskell (book, Markdown)", DOCS_DIR / "haskell/lyah/source_md", "text"),
            DocEntry("GHC base library (haddock)", _first("haskell/base-*-docs/index.html"), "html"),
        ],
        "swift": [
            DocEntry("The Swift Programming Language (Markdown)", DOCS_DIR / "swift/swift-book/TSPL.docc", "text")
        ],
        "sv": [
            DocEntry("SystemVerilog track READMEs", TRACKS_DIR / "systemverilog", "text"),
            DocEntry("Verilator user guide (rST)", DOCS_DIR / "sv/verilator/docs/guide", "text"),
            DocEntry("Verilator examples", _verilator_examples(), "text"),
        ],
        "shell": [DocEntry("Shell track READMEs (grep/rg/sed/awk)", TRACKS_DIR / "shell", "text")],
    }


ALIASES = {"c++": "cpp", "py": "python", "hs": "haskell", "systemverilog": "sv", "verilog": "sv", "bash": "shell"}


def entries_for(lang: str) -> list[DocEntry] | None:
    return registry().get(ALIASES.get(lang, lang))


def can_open_gui() -> bool:
    if os.environ.get("SSH_CONNECTION") or os.environ.get("SSH_TTY"):
        return False
    if platform.system() == "Darwin":
        return True
    return bool(os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY"))


def open_in_browser(path: Path) -> bool:
    opener = "open" if platform.system() == "Darwin" else "xdg-open"
    if not can_open_gui() or shutil.which(opener) is None:
        return False
    return subprocess.run([opener, str(path)], check=False).returncode == 0
