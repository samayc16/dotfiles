"""Terminal output: colours, spinner, step lines and the summary table.

Colour is used only on a TTY and never when NO_COLOR is set; on a non-TTY (CI, pipes)
output is plain line-by-line text so logs stay readable.
"""

from __future__ import annotations

import itertools
import os
import re
import shutil
import sys
import threading
import time
from typing import Iterable, Optional, TextIO

# Monokai Pro, matching kitty/tmux/nvim
PALETTE = {
    "green": (169, 220, 118),
    "yellow": (255, 216, 102),
    "red": (255, 97, 136),
    "cyan": (120, 220, 232),
    "purple": (171, 157, 242),
    "orange": (252, 152, 103),
    "gray": (114, 112, 114),
}
SYMBOLS = {"ok": "✓", "failed": "✗", "skipped": "–", "dry": "○"}
STATUS_COLOR = {"ok": "green", "failed": "red", "skipped": "gray", "dry": "cyan"}
SPINNER_FRAMES = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
ANSI_RE = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")


def strip_ansi(text: str) -> str:
    return ANSI_RE.sub("", text)


class Ui:
    """All user-facing output goes through here."""

    def __init__(self, stream: Optional[TextIO] = None, color: Optional[bool] = None) -> None:
        self.stream = stream if stream is not None else sys.stdout
        self.tty = self.stream.isatty()
        self.color = (self.tty and "NO_COLOR" not in os.environ) if color is None else color

    def paint(self, text: str, color: Optional[str] = None, bold: bool = False, dim: bool = False) -> str:
        if not self.color:
            return text
        codes = []
        if bold:
            codes.append("1")
        if dim:
            codes.append("2")
        if color:
            codes.append("38;2;%d;%d;%d" % PALETTE[color])
        return "\x1b[%sm%s\x1b[0m" % (";".join(codes), text) if codes else text

    def line(self, text: str = "") -> None:
        print(text, file=self.stream, flush=True)

    def banner(self, title: str, facts: Iterable[str]) -> None:
        self.line()
        self.line("  " + self.paint(title, "purple", bold=True))
        self.line("  " + self.paint("  ·  ".join(facts), dim=True))
        self.line()

    def step_header(self, name: str, summary: str) -> None:
        """Used when a step streams its own output (CI or interactive steps)."""
        self.line(self.paint("── %s " % name, "cyan", bold=True) + self.paint(summary, dim=True))

    def step_result(self, name: str, summary: str, status: str, seconds: float, note: str = "") -> None:
        symbol = self.paint(SYMBOLS[status], STATUS_COLOR[status], bold=True)
        label = self.paint(name.ljust(9), bold=status != "skipped", dim=status == "skipped")
        text = note if status in ("skipped", "failed") and note else summary
        text = self.paint(text, dim=status == "skipped")
        timing = self.paint("%5.1fs" % seconds, dim=True) if status not in ("skipped",) else ""
        self.line("  %s %s %s  %s" % (symbol, label, text, timing))

    def detail(self, lines: Iterable[str], color: Optional[str] = None) -> None:
        for raw in lines:
            self.line("      " + self.paint(strip_ansi(raw).rstrip(), color, dim=color is None))

    def summary(self, results: list, log_path: Optional[str]) -> None:
        counts = {status: sum(1 for r in results if r.status == status) for status in SYMBOLS}
        parts = []
        for status in ("ok", "dry", "skipped", "failed"):
            if counts[status]:
                parts.append(self.paint("%d %s" % (counts[status], status), STATUS_COLOR[status], bold=status == "failed"))
        self.line()
        self.line("  " + self.paint("Summary", bold=True) + "  " + "  ".join(parts))
        failed = [r for r in results if r.status == "failed"]
        for result in failed:
            self.line("    %s %s — re-run with: ./install.sh --only %s" % (self.paint(SYMBOLS["failed"], "red"), result.name, result.name))
        if log_path:
            self.line("  " + self.paint("log: " + log_path, dim=True))
        self.line()


class Spinner:
    """Animated status line for a running step (TTY only). Shows the step's latest output."""

    def __init__(self, ui: Ui, name: str) -> None:
        self.ui = ui
        self.name = name
        self.status = ""
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._spin, daemon=True)

    def __enter__(self) -> "Spinner":
        if self.ui.tty:
            self._thread.start()
        return self

    def __exit__(self, *exc: object) -> None:
        self._stop.set()
        if self.ui.tty:
            self._thread.join()
            self.ui.stream.write("\r\x1b[2K")
            self.ui.stream.flush()

    def update(self, text: str) -> None:
        clean = strip_ansi(text).strip()
        if clean:
            self.status = clean

    def _spin(self) -> None:
        for frame in itertools.cycle(SPINNER_FRAMES):
            if self._stop.is_set():
                return
            width = shutil.get_terminal_size((80, 20)).columns
            text = "  %s %s %s" % (self.ui.paint(frame, "cyan"), self.ui.paint(self.name.ljust(9), bold=True), self.ui.paint(self.status, dim=True))
            visible = strip_ansi(text)
            if len(visible) > width - 1:
                text = text[: len(text) - (len(visible) - width + 2)] + "…"
            self.ui.stream.write("\r\x1b[2K" + text)
            self.ui.stream.flush()
            time.sleep(0.08)
