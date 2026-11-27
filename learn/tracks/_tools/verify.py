#!/usr/bin/env python3
"""Prove a learn track end to end, through the real `learn` CLI a learner uses.

For every exercise: `learn start --print` makes a fresh workspace, `learn check` run from
inside it must FAIL on the untouched starter (with the harness actually running, not a
crash), the reference solution is copied in, and `learn check` must PASS and record the
pass in progress.json. Everything happens in a throwaway LEARN_HOME, never ~/learn.

Usage: python3 learn/tracks/_tools/verify.py TRACK [SLUG ...] [--require] [--limit N]
  --require      a missing toolchain fails the run (for CI) instead of skipping the track
  --limit N      only the first N exercises (Exercism tracks have 100+)
  --home DIR     use DIR as LEARN_HOME (keeps build caches; Exercism tracks need DIR/vendor)
Exit: 0 verified or skipped, 1 a problem was found, 2 usage error. Python 3.8+, stdlib only.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, NamedTuple, Optional

REPO = Path(__file__).resolve().parents[3]
LEARN = REPO / "bin" / "learn"
TRACKS = REPO / "learn" / "tracks"
TOOLCHAIN_MISSING = 127  # `learn check` exit code when the checker itself couldn't run
STEP_TIMEOUT_S = 1200

# A failing starter must end in a verdict a beginner can act on: the checks ran, the code
# doesn't compile yet (many C++/Swift koans start that way on purpose), or a sanitizer crash
# summary. Anything else (a traceback, a broken harness) is a bug in the track.
VERDICT = {
    "shell": r"✗",
    "systemverilog": r"✗",
    "haskell-koans": r"^☯ ",
    "c-koans": r"checks passing|doesn't compile yet|✗ crashed",
    "cpp-koans": r"checks passing|doesn't compile yet|✗ crashed",
    "swift-koans": r"checks passing|doesn't compile yet",
    "python-koans": r"checks passing",
    "rust-koans": r"checks passing|doesn't compile yet",
}
# Tracks whose starters must compile and run the checks, unless "starter_compiles": false.
HARNESS_RAN = {"haskell-koans": r"^☯ ", "rust-koans": r"checks passing"}


class Result(NamedTuple):
    code: int
    output: str


class Exercise(NamedTuple):
    key: str
    slug: str
    compiles: bool


def run_learn(args: List[str], cwd: Path, env: Dict[str, str]) -> Result:
    # Stdin is an empty pipe, as when Claude or a script runs `learn check`: the hardest case for
    # checkers (ripgrep with no path searches a piped stdin instead of the directory).
    proc = subprocess.run(
        [sys.executable, str(LEARN), *args],
        cwd=str(cwd),
        env=env,
        input="",
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        universal_newlines=True,
        timeout=STEP_TIMEOUT_S,
    )
    return Result(proc.returncode, proc.stdout)


def exercises_for(track: str, home: Path, env: Dict[str, str]) -> List[Exercise]:
    result = run_learn(["status"], home, env)
    if result.code != 0:
        raise SystemExit(f"learn status failed:\n{result.output}")
    status = json.loads(result.output.splitlines()[-1])
    found = next((t for t in status["tracks"] if t["slug"] == track), None)
    if found is None:
        raise SystemExit(f"no track {track!r}: {', '.join(t['slug'] for t in status['tracks'])}")
    exercises = []
    for ex in found["exercises"]:
        slug = ex["key"].split("/", 1)[1]
        meta_path = TRACKS / track / slug / "exercise.json"
        meta = json.loads(meta_path.read_text()) if meta_path.is_file() else {}
        exercises.append(Exercise(ex["key"], slug, meta.get("starter_compiles", True) is not False))
    return exercises


def reference_files(track: str, slug: str, ws: Path, home: Path) -> Dict[Path, Path]:
    """{source: destination in the workspace} for the exercise's reference solution."""
    solution = TRACKS / track / slug / "solution"
    if solution.is_dir():
        return {src: ws / src.relative_to(solution) for src in sorted(solution.rglob("*")) if src.is_file()}
    for kind in ("concept", "practice"):
        ex_dir = home / "vendor" / track / "exercises" / kind / slug
        config = ex_dir / ".meta" / "config.json"
        if config.is_file():
            files = json.loads(config.read_text()).get("files", {})
            refs = files.get("example") or files.get("exemplar") or []
            return {ex_dir / ref: ws / dst for ref, dst in zip(refs, files.get("solution", []))}
    return {}


def progress_entry(home: Path, key: str) -> dict:
    data = json.loads((home / "progress.json").read_text())
    return data["exercises"].get(key, {})


def indent(text: str, limit: int = 30) -> str:
    lines = text.rstrip().splitlines()
    shown = lines[-limit:]
    return "\n".join(f"    {line}" for line in shown)


def summary_line(output: str) -> str:
    """The checker's own last word on the starter (learn's "Not yet" line is the same every time)."""
    lines = [line.strip() for line in output.splitlines() if line.strip() and "Not yet" not in line]
    return lines[-1][:70] if lines else ""


def verify_one(ex: Exercise, track: str, home: Path, env: Dict[str, str]) -> Optional[str]:
    """None when the exercise is fine, else a description of the problem."""
    reset = run_learn(["reset", ex.key, "--yes"], home, env)  # a reused --home may hold an old attempt
    if reset.code != 0:
        return f"`learn reset` failed\n{indent(reset.output)}"
    started = run_learn(["start", ex.key, "--print", "--force"], home, env)
    if started.code != 0:
        return f"`learn start` failed\n{indent(started.output)}"
    ws = Path(json.loads(started.output.splitlines()[-1])["workspace"])
    starter = run_learn(["check"], ws, env)
    if starter.code == TOOLCHAIN_MISSING:
        raise ToolchainMissing(starter.output)
    if starter.code == 0:
        return "the untouched starter PASSES"
    if "Traceback (most recent call last)" in starter.output:
        return f"`learn check` crashed on the starter\n{indent(starter.output)}"
    verdict, ran = VERDICT.get(track), HARNESS_RAN.get(track)
    if verdict and not re.search(verdict, starter.output, re.MULTILINE):
        return f"the starter fails without a clear verdict (expected /{verdict}/)\n{indent(starter.output)}"
    if ex.compiles and ran and not re.search(ran, starter.output, re.MULTILINE):
        return f"the starter's checks never ran (expected /{ran}/)\n{indent(starter.output)}"
    if not ex.compiles and ran and "doesn't compile yet" not in starter.output:
        return f"the starter should start with a compile error (starter_compiles: false)\n{indent(starter.output)}"
    refs = reference_files(track, ex.slug, ws, home)
    if not refs:
        return "no reference solution found"
    for src, dst in refs.items():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(str(src), str(dst))
    solved = run_learn(["check"], ws, env)
    if solved.code != 0:
        return f"the reference solution FAILS\n{indent(solved.output, 40)}"
    entry = progress_entry(home, ex.key)
    if not (entry.get("passed") and entry.get("stars", 0) >= 1 and entry.get("xp", 0) > 0):
        return f"passed, but progress.json didn't record it: {entry}"
    print(f"✔ {ex.slug:<34} starter: {summary_line(starter.output)}")
    return None


class ToolchainMissing(Exception):
    pass


def make_env(home: Path) -> Dict[str, str]:
    env = {k: v for k, v in os.environ.items() if k != "LEARN_FORCE_COLOR"}
    env.update(LEARN_HOME=str(home), NO_COLOR="1")
    return env


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("track")
    parser.add_argument("slugs", nargs="*")
    parser.add_argument("--require", action="store_true", help="fail, don't skip, when a toolchain is missing")
    parser.add_argument("--limit", type=int, default=0, help="only the first N exercises")
    parser.add_argument("--home", type=Path, help="LEARN_HOME to use (never ~/learn)")
    return parser.parse_args(argv)


def verify(args: argparse.Namespace, home: Path) -> int:
    env = make_env(home)
    exercises = exercises_for(args.track, home, env)
    if args.slugs:
        wanted = set(args.slugs)
        exercises = [ex for ex in exercises if ex.slug in wanted]
    if args.limit:
        exercises = exercises[: args.limit]
    problems = 0
    for ex in exercises:
        try:
            problem = verify_one(ex, args.track, home, env)
        except ToolchainMissing as missing:
            print(indent(str(missing), 6))
            if args.require:
                print(f"✘ {args.track}: its toolchain is missing (--require)")
                return 1
            print(f"- {args.track}: skipped, its toolchain isn't installed here")
            return 0
        except subprocess.TimeoutExpired:
            problem = f"timed out after {STEP_TIMEOUT_S}s"
        if problem:
            problems += 1
            print(f"✘ {ex.slug}: {problem}")
    print()
    if problems:
        print(f"{args.track}: {problems} problem(s) in {len(exercises)} exercises.")
        return 1
    print(f"{args.track}: all {len(exercises)} verified: every starter fails, every reference solution passes.")
    return 0


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    if args.home:
        home = args.home.resolve()
        if home == (Path.home() / "learn").resolve():
            print("refusing to verify in ~/learn: it holds your real progress", file=sys.stderr)
            return 2
        home.mkdir(parents=True, exist_ok=True)
        stale = home / "progress.json"
        if stale.exists():
            stale.unlink()  # every exercise starts unpassed, so each check is scored afresh
        return verify(args, home)
    with tempfile.TemporaryDirectory(prefix=f"learn-verify-{args.track}.") as tmp:
        return verify(args, Path(tmp))


if __name__ == "__main__":
    sys.exit(main())
