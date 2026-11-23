"""Run a Rust koan's checks and print one ✓/✗ line per check.

The learner's crate is built from the workspace's src/ only; the manifest and
tests/checks.rs come from the pristine exercise dir, so edited copies in the workspace
change nothing. Each #[test] in tests/checks.rs is one check, reported in source order
with expected-vs-got, then "N/M checks passing". On a full pass, clippy's warnings for
the learner's code are shown as optional tips.

Builds live in one CARGO_TARGET_DIR under $LEARN_HOME/.cache/rust-koans, with a stable
manifest dir per workspace, so an unchanged re-check doesn't recompile anything.

Run by check-rust.sh (cargo is on PATH by then). Env: LEARN_EXERCISE_DIR, LEARN_WORKSPACE,
LEARN_HOME, NO_COLOR / LEARN_FORCE_COLOR, KOAN_TIMEOUT (seconds). Python 3.8+, stdlib only.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from itertools import takewhile
from pathlib import Path
from typing import Dict, List, Optional, Tuple

TEST_TARGET = "checks"
DEFAULT_TIMEOUT_S = 20
BUILD_TIMEOUT_S = 600
MAX_ERROR_LINES = 80
MAX_TIPS = 6
MAX_PRINTED = 5

PANIC = re.compile(r"^thread '[^']*'(?: \(\d+\))? panicked at (.+):(\d+):(\d+):$")
RESULT = re.compile(r"^test (\S+) \.\.\. (ok|FAILED|ignored)\b")
SECTION = re.compile(r"^---- (\S+) stdout ----$")
TEST_FN = re.compile(r"#\[test\]\s*(?:#\[[^\]]*\]\s*)*(?:pub\s+)?fn\s+(\w+)")
MANIFEST_PATH = re.compile(r'^(\s*path\s*=\s*)"((?:src|tests)/[^"]*)"\s*$')
ASSERT_CMP = re.compile(r"^assertion `left (==|!=) right` failed(?:: (.*))?$")
ERROR_AT = re.compile(r"^\s*--> (\S+?):\d+:\d+")
ANSI = re.compile(r"\x1b\[[0-9;]*m")
BACKTRACE_NOTE = "note: run with `RUST_BACKTRACE"

COLORS = {"green": (169, 220, 118), "red": (255, 97, 136), "yellow": (255, 216, 102), "gray": (114, 112, 114)}


@dataclass(frozen=True)
class Style:
    enabled: bool

    def paint(self, text: str, color: str) -> str:
        if not self.enabled:
            return text
        r, g, b = COLORS[color]
        return f"\033[38;2;{r};{g};{b}m{text}\033[0m"


@dataclass(frozen=True)
class Paths:
    exercise: Path
    workspace: Path
    cache: Path
    build: Path

    def relative(self, text: str) -> str:
        """Absolute paths in compiler/panic output → the paths the learner sees in the workspace."""
        roots = sorted((self.workspace, self.exercise, self.build), key=lambda p: len(str(p)), reverse=True)
        for root in roots:
            text = text.replace(f"{root}/", "")
        return text


@dataclass(frozen=True)
class TestRun:
    stdout: str
    stderr: str
    timed_out: bool
    crashed: bool


@dataclass(frozen=True)
class Outcome:
    name: str
    passed: bool
    detail: str = ""
    printed: Tuple[str, ...] = ()


# ── setup ────────────────────────────────────────────────────────────────────


def color_enabled() -> bool:
    if os.environ.get("NO_COLOR"):
        return False
    if os.environ.get("LEARN_FORCE_COLOR"):
        return True
    return sys.stdout.isatty()


def locate() -> Paths:
    exercise = Path(os.environ["LEARN_EXERCISE_DIR"]).resolve()
    workspace = Path(os.environ.get("LEARN_WORKSPACE") or os.getcwd()).resolve()
    home = Path(os.environ.get("LEARN_HOME") or Path.home() / "learn").resolve()
    cache = home / ".cache" / "rust-koans"
    key = hashlib.sha256(str(workspace).encode()).hexdigest()[:12]
    return Paths(exercise, workspace, cache, cache / "check" / f"{exercise.name}-{key}")


def timeout_s() -> int:
    try:
        return max(1, int(os.environ.get("KOAN_TIMEOUT", DEFAULT_TIMEOUT_S)))
    except ValueError:
        return DEFAULT_TIMEOUT_S


def _absolute(line: str, paths: Paths) -> str:
    match = MANIFEST_PATH.match(line)
    if not match:
        return line
    root = paths.workspace if match.group(2).startswith("src/") else paths.exercise
    return match.group(1) + json.dumps(str(root / match.group(2)), ensure_ascii=False)


def write_manifest(paths: Paths) -> None:
    """The exercise's Cargo.toml with src/ pointing into the workspace and tests/ into the exercise."""
    lines = (paths.exercise / "Cargo.toml").read_text().splitlines()
    text = "\n".join(_absolute(line, paths) for line in lines) + "\n"
    target = paths.build / "Cargo.toml"
    paths.build.mkdir(parents=True, exist_ok=True)
    if not target.is_file() or target.read_text() != text:  # rewriting would invalidate cargo's cache
        target.write_text(text)


def cargo_env(paths: Paths, *, quiet_warnings: bool, color: bool) -> Dict[str, str]:
    ignored = {"RUSTFLAGS", "CARGO_ENCODED_RUSTFLAGS", "CARGO_BUILD_RUSTFLAGS"}
    env = {k: v for k, v in os.environ.items() if k not in ignored}
    env["CARGO_TARGET_DIR"] = str(paths.cache / "target")
    env["CARGO_TERM_COLOR"] = "always" if color else "never"
    if quiet_warnings:
        env["RUSTFLAGS"] = "-Awarnings"  # errors only while compiling; warnings return as clippy tips on a pass
    return env


def _run(cmd: List[str], cwd: Path, env: Dict[str, str], timeout: int) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd, cwd=cwd, env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout
    )


# ── build ────────────────────────────────────────────────────────────────────


def _executable(json_lines: str) -> Optional[str]:
    for line in json_lines.splitlines():
        try:
            message = json.loads(line)
        except ValueError:
            continue
        target = message.get("target") or {}
        if message.get("reason") == "compiler-artifact" and target.get("name") == TEST_TARGET:
            if message.get("executable"):
                return str(message["executable"])
    return None


def compile_checks(paths: Paths, env: Dict[str, str]) -> Tuple[Optional[str], str]:
    """(the checks executable, or None if the build failed; cargo's rendered diagnostics)."""
    cmd = ["cargo", "test", "--offline", "--quiet", "--no-run", "--test", TEST_TARGET]
    proc = _run([*cmd, "--message-format=json-render-diagnostics"], paths.build, env, BUILD_TIMEOUT_S)
    exe = _executable(proc.stdout) if proc.returncode == 0 else None
    return exe, proc.stderr


def report_compile_errors(output: str, paths: Paths, style: Style) -> None:
    lines = paths.relative(output).rstrip().splitlines()
    print("\n".join(lines[:MAX_ERROR_LINES]))
    if len(lines) > MAX_ERROR_LINES:
        more = len(lines) - MAX_ERROR_LINES
        print(style.paint(f"… {more} more lines: run `cargo test` in the workspace, or read them in nvim", "gray"))
    locations = (ERROR_AT.match(ANSI.sub("", line)) for line in lines)
    first = next((m.group(1) for m in locations if m), "")
    if first.startswith("tests/"):
        hint = (
            "the first error is in tests/checks.rs, where the checks use your code: "
            "make your names, visibility and signatures (lifetimes too) fit how they're used there"
        )
    else:
        hint = "fix the first error above (in nvim: ]d next diagnostic · <leader>ce explains it · gra quick fixes)"
    print(f"{style.paint('✗', 'red')} doesn't compile yet: {hint}")


# ── run and explain ──────────────────────────────────────────────────────────


def _text(output: object) -> str:
    if isinstance(output, bytes):
        return output.decode("utf-8", errors="replace")
    return output if isinstance(output, str) else ""


def run_checks(exe: str, paths: Paths, timeout: int) -> TestRun:
    env = {**os.environ, "RUST_BACKTRACE": "0"}
    try:
        proc = _run([exe, "--color", "never"], paths.workspace, env, timeout)
    except subprocess.TimeoutExpired as exc:
        return TestRun(_text(exc.stdout), _text(exc.stderr), timed_out=True, crashed=False)
    return TestRun(proc.stdout, proc.stderr, timed_out=False, crashed=proc.returncode not in (0, 101))


def parse(stdout: str) -> Tuple[Dict[str, str], Dict[str, List[str]]]:
    """libtest's report → ({test: ok|FAILED|ignored}, {failed test: its captured output})."""
    statuses: Dict[str, str] = {}
    sections: Dict[str, List[str]] = {}
    current: Optional[str] = None
    for line in stdout.splitlines():
        header = SECTION.match(line)
        if header:
            current = header.group(1)
            sections[current] = []
        elif current is not None and line == "failures:":
            current = None  # the name list that follows the captured sections
        elif current is not None:
            sections[current].append(line)
        else:
            result = RESULT.match(line)
            if result:
                statuses[result.group(1)] = result.group(2)
    return statuses, sections


def explain(message: List[str], where: str) -> str:
    first = message[0] if message else ""
    if first.startswith(("not yet implemented", "not implemented")):
        return f"not implemented yet: replace the todo!() at {where}"
    compared = ASSERT_CMP.match(first)
    if compared:
        values = {line.split(":", 1)[0].strip(): line.split(":", 1)[1].strip() for line in message[1:] if ":" in line}
        got, want = values.get("left", "?"), values.get("right", "?")
        core = f"expected {want}, got {got}" if compared.group(1) == "==" else f"expected anything but {want}"
        return f"{compared.group(2)}: {core}" if compared.group(2) else core
    text = " ".join(line.strip() for line in message if line.strip()) or "panicked"
    return f"panicked at {where}: {text}" if where.startswith("src/") else text


def failure_detail(section: List[str], paths: Paths) -> Tuple[str, Tuple[str, ...]]:
    """(why it failed, what the learner's code printed before the first panic)."""
    for i, line in enumerate(section):
        panic = PANIC.match(line)
        if panic:
            where = f"{paths.relative(panic.group(1))}:{panic.group(2)}:{panic.group(3)}"
            rest = section[i + 1 :]
            message = list(takewhile(lambda l: not l.startswith(BACKTRACE_NOTE) and not PANIC.match(l), rest))
            printed = tuple(l for l in section[:i] if l.strip())
            return explain(message, where), printed
    return "failed", tuple(l for l in section if l.strip())


def outcome(name: str, status: Optional[str], section: List[str], run: TestRun, paths: Paths, timeout: int) -> Outcome:
    if status == "ok":
        return Outcome(name, True)
    if status == "FAILED" and section:
        detail, printed = failure_detail(section, paths)
        return Outcome(name, False, detail, printed)
    if status == "FAILED":
        problem = "crash" if run.crashed else "hang"
        return Outcome(name, False, f"failed (its details were lost: fix the {problem} first)")
    if status == "ignored":
        return Outcome(name, False, "ignored: remove its #[ignore]")
    if run.timed_out:
        return Outcome(name, False, f"still running after {timeout}s: an infinite loop, or threads waiting on each other?")
    if run.crashed:
        return Outcome(name, False, "never finished: the checks crashed (see below)")
    return Outcome(name, False, "didn't run")


def collect(names: List[str], run: TestRun, paths: Paths, timeout: int) -> List[Outcome]:
    statuses, sections = parse(run.stdout)
    ordered = names + sorted(n for n in statuses if n not in names)
    return [outcome(n, statuses.get(n), sections.get(n, []), run, paths, timeout) for n in ordered]


def report(results: List[Outcome], run: TestRun, paths: Paths, style: Style) -> None:
    for result in results:
        if result.passed:
            print(f"  {style.paint('✓', 'green')} {result.name}")
            continue
        print(f"  {style.paint('✗', 'red')} {result.name} — {result.detail}")
        for line in result.printed[:MAX_PRINTED]:
            print(style.paint(f"      │ {line}", "gray"))
    if run.crashed:
        tail = paths.relative(run.stderr).strip().splitlines()[-5:]
        print(style.paint("\n  the checks crashed:", "red"))
        print("\n".join(f"    {line}" for line in tail))
    passed = sum(1 for r in results if r.passed)
    print(f"\n  {passed}/{len(results)} checks passing")


# ── clippy tips ──────────────────────────────────────────────────────────────


def clippy_tips(paths: Paths) -> List[str]:
    env = cargo_env(paths, quiet_warnings=False, color=False)
    cmd = ["cargo", "clippy", "--offline", "--quiet", "--message-format=short"]
    try:
        proc = _run(cmd, paths.build, env, BUILD_TIMEOUT_S)
    except (OSError, subprocess.TimeoutExpired):
        return []  # tips are a bonus: never fail a passing koan over them
    lines = paths.relative(proc.stderr).splitlines()
    return [l for l in lines if l.startswith("src/") and (": warning: " in l or ": error: " in l)]


def show_tips(tips: List[str], style: Style) -> None:
    if not tips:
        return
    print(style.paint(f"\n  clippy has {len(tips)} tip{'s' if len(tips) != 1 else ''} (optional: it already passes)", "yellow"))
    for tip in tips[:MAX_TIPS]:
        print(f"    {tip}")
    if len(tips) > MAX_TIPS:
        print(f"    … and {len(tips) - MAX_TIPS} more")
    print(style.paint("  `cargo clippy` in the workspace explains each one; nvim shows them inline on save", "gray"))


# ── main ─────────────────────────────────────────────────────────────────────


def main() -> int:
    style = Style(color_enabled())
    if not os.environ.get("LEARN_EXERCISE_DIR"):
        print(f"{style.paint('✗', 'red')} LEARN_EXERCISE_DIR is not set: run this via `learn check`")
        return 2
    paths = locate()
    if not (paths.workspace / "src" / "lib.rs").is_file():
        key = f"{paths.exercise.parent.name}/{paths.exercise.name}"
        print(f"{style.paint('✗', 'red')} src/lib.rs is missing: restore it, or start over with `learn reset {key}`")
        return 1
    write_manifest(paths)
    try:
        exe, output = compile_checks(paths, cargo_env(paths, quiet_warnings=True, color=style.enabled))
    except subprocess.TimeoutExpired:
        print(f"{style.paint('✗', 'red')} cargo took over {BUILD_TIMEOUT_S}s to build the checks")
        return 1
    if exe is None:
        report_compile_errors(output, paths, style)
        return 1
    names = TEST_FN.findall((paths.exercise / "tests" / f"{TEST_TARGET}.rs").read_text())
    limit = timeout_s()
    run = run_checks(exe, paths, limit)
    results = collect(names, run, paths, limit)
    report(results, run, paths, style)
    passed = bool(results) and all(r.passed for r in results)
    if passed:
        show_tips(clippy_tips(paths), style)
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
