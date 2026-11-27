"""Shared helpers: an isolated LEARN_HOME, synthetic tracks, and running the real CLI.

Import this before learnlib in every test module: learnlib derives its paths from LEARN_HOME
when it is imported, and no test may ever fall back to the learner's real ~/learn.
"""

from __future__ import annotations

import atexit
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple
from unittest import mock

_FALLBACK_HOME = tempfile.mkdtemp(prefix="learn-tests-home.")
atexit.register(shutil.rmtree, _FALLBACK_HOME, True)
os.environ["LEARN_HOME"] = _FALLBACK_HOME

from learnlib import cli, docs, exercism, progress, tracks, workspace  # noqa: E402

REPO = Path(__file__).resolve().parents[2]
LEARN_BIN = REPO / "bin" / "learn"
ANSI_FREE_ENV = {"NO_COLOR": "1"}

# check.sh for synthetic exercises: the learner "solves" it by writing `pass` into answer.txt.
# `toolchain` simulates a missing compiler (the 127 convention every checker follows).
SYNTHETIC_CHECK = """#!/usr/bin/env bash
answer=$(cat "$LEARN_WORKSPACE/answer.txt" 2>/dev/null)
echo "checking: $answer"
case "$answer" in
  pass) echo "1/1 checks passing"; exit 0 ;;
  toolchain) echo "✗ frobc not found: install it"; exit 127 ;;
  *) echo "0/1 checks passing"; exit 1 ;;
esac
"""


def write_json(path: Path, data: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data))


def make_track(root: Path, slug: str = "demo", count: int = 5, hints: int = 2) -> Path:
    """A synthetic track under root/<slug> with `count` exercises 01-ex .. NN-ex."""
    track_dir = root / slug
    order = [f"{i:02d}-ex" for i in range(1, count + 1)]
    write_json(track_dir / "track.json", {"name": f"{slug} track", "slug": slug, "language": "", "order": order})
    for name in order:
        ex = track_dir / name
        write_json(
            ex / "exercise.json",
            {
                "title": f"Exercise {name}",
                "difficulty": 1,
                "xp": 10,
                "files": ["answer.txt"],
                "hints": [f"hint {i + 1} for {name}" for i in range(hints)],
            },
        )
        (ex / "answer.txt").write_text("starter\n")
        (ex / "README.md").write_text(f"# {name}\n")
        (ex / "check.sh").write_text(SYNTHETIC_CHECK)
        (ex / "solution").mkdir()
        (ex / "solution" / "answer.txt").write_text("pass\n")
    return track_dir


class IsolatedHome(unittest.TestCase):
    """Every learnlib path that derives from LEARN_HOME points into a fresh temp dir.

    With `synthetic=True` the only track is a 5-exercise synthetic one (no toolchain needed).
    """

    synthetic = True

    def setUp(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.home = Path(tmp.name).resolve()
        self.tracks_dir = self.home / "tracks"
        self.tracks_dir.mkdir()
        if self.synthetic:
            make_track(self.tracks_dir)
        patches = [
            mock.patch.object(progress, "PROGRESS_FILE", self.home / "progress.json"),
            mock.patch.object(progress, "LEARN_HOME", self.home),
            mock.patch.object(workspace, "LEARN_HOME", self.home),
            mock.patch.object(workspace, "WORKSPACE_ROOT", self.home / "workspace"),
            mock.patch.object(workspace, "VENV_DIR", self.home / ".venv"),
            mock.patch.object(workspace, "SWAP_DIRS", (), create=True),
            mock.patch.object(exercism, "VENDOR_DIR", self.home / "vendor"),
            mock.patch.object(docs, "DOCS_DIR", self.home / "docs"),
        ]
        if self.synthetic:
            patches.append(mock.patch.object(tracks, "TRACKS_DIR", self.tracks_dir))
        for patcher in patches:
            patcher.start()
            self.addCleanup(patcher.stop)
        cwd = os.getcwd()
        self.addCleanup(os.chdir, cwd)
        os.chdir(self.home)
        env = mock.patch.dict(os.environ, {"NO_COLOR": "1"})
        env.start()
        self.addCleanup(env.stop)
        os.environ.pop("LEARN_FORCE_COLOR", None)

    def ws(self, slug: str = "01-ex", track: str = "demo") -> Path:
        return self.home / "workspace" / track / slug

    def entry(self, key: str) -> dict:
        return progress.entry(progress.load(self.home / "progress.json"), key)

    def learn(self, *args: str, cwd: Optional[Path] = None) -> Tuple[int, str]:
        """cli.main in-process, from `cwd`; returns (exit code, stdout+stderr incl. the checker's)."""
        os.chdir(cwd or self.home)
        return run_main(args)

    def start(self, slug: str = "01-ex") -> Path:
        code, out = self.learn("start", f"demo/{slug}", "--print", "--force")
        self.assertEqual(code, 0, out)
        return Path(last_json(out)["workspace"])

    def solve(self, slug: str = "01-ex") -> None:
        (self.start(slug) / "answer.txt").write_text("pass\n")
        code, out = self.learn("check", cwd=self.ws(slug))
        self.assertEqual(code, 0, out)


def run_main(args: Iterable[str]) -> Tuple[int, str]:
    """Run cli.main with fds 1 and 2 (so the checker subprocess too) captured into one stream."""
    with tempfile.TemporaryFile() as captured:
        sys.stdout.flush()
        sys.stderr.flush()
        saved = os.dup(1), os.dup(2)
        streams = sys.stdout, sys.stderr
        os.dup2(captured.fileno(), 1)
        os.dup2(captured.fileno(), 2)
        writer = io.TextIOWrapper(os.fdopen(os.dup(1), "wb"), encoding="utf-8", write_through=True)
        sys.stdout = sys.stderr = writer
        try:
            code = cli.main(list(args))
        except SystemExit as exc:
            code = exc.code if isinstance(exc.code, int) else 1
            if not isinstance(exc.code, int) and exc.code is not None:
                print(exc.code)
        finally:
            writer.flush()
            sys.stdout, sys.stderr = streams
            writer.close()
            os.dup2(saved[0], 1)
            os.dup2(saved[1], 2)
            os.close(saved[0])
            os.close(saved[1])
        captured.seek(0)
        return code, captured.read().decode("utf-8", "replace")


def run_cli(
    args: Iterable[str], home: Path, cwd: Optional[Path] = None, env: Optional[Dict[str, str]] = None
) -> subprocess.CompletedProcess:
    """Run bin/learn exactly as a learner would, with stdout and stderr captured (pipes, not a TTY)."""
    full_env = {k: v for k, v in os.environ.items() if k not in ("LEARN_FORCE_COLOR", "NO_COLOR")}
    full_env.update({"LEARN_HOME": str(home), **(env or {})})
    return subprocess.run(
        [sys.executable, str(LEARN_BIN), *args],
        cwd=str(cwd or home),
        env=full_env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
        timeout=300,
    )


def last_json(stdout: str) -> dict:
    return json.loads(stdout.strip().splitlines()[-1])


def tool_path(tmp: Path, tools: List[str]) -> str:
    """A PATH holding only `tools` (symlinked), to simulate a machine missing everything else."""
    bin_dir = tmp / "bin"
    bin_dir.mkdir(exist_ok=True)
    for tool in tools:
        found = next((Path(d) / tool for d in os.environ.get("PATH", "").split(os.pathsep) if (Path(d) / tool).is_file()), None)
        if found and not (bin_dir / tool).exists():
            (bin_dir / tool).symlink_to(found)
    return str(bin_dir)
