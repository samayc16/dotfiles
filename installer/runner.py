"""Run one step script, capture/stream its output, and turn the exit code into a Result."""

from __future__ import annotations

import os
import subprocess
import threading
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, TextIO

from .host import Host
from .steps import Step
from .ui import Spinner, Ui, strip_ansi

SKIP_EXIT = 3  # install.d/lib.sh: a step exits 3 when it has nothing to do
TAIL_ON_FAILURE = 15


@dataclass(frozen=True)
class Result:
    name: str
    status: str  # ok | skipped | failed | dry
    seconds: float
    note: str = ""


@dataclass(frozen=True)
class Context:
    root: Path  # the dotfiles repo
    host: Host
    env: Dict[str, str]  # environment for step scripts
    ui: Ui
    log: Optional[TextIO]
    dry_run: bool
    verbose: bool


def _status(code: int, dry_run: bool) -> str:
    if code == SKIP_EXIT:
        return "skipped"
    if code != 0:
        return "failed"
    return "dry" if dry_run else "ok"


def _note(lines: List[str], status: str) -> str:
    """One-line explanation for the summary: the step's skip reason or its last error."""
    clean = [strip_ansi(line).strip() for line in lines if line.strip()]
    if status == "skipped":
        reasons = [line.split("skip:", 1)[1].strip() for line in clean if "skip:" in line]
        return reasons[-1] if reasons else "nothing to do"
    if status == "failed":
        errors = [line.lstrip("✗! ").strip() for line in clean if line.startswith(("✗", "!"))]
        return errors[-1] if errors else (clean[-1] if clean else "failed")
    return ""


def _log(ctx: Context, text: str) -> None:
    if ctx.log:
        ctx.log.write(text)
        ctx.log.flush()


def _capture(ctx: Context, step: Step, argv: List[str]) -> Result:
    """TTY mode: spinner with the latest output line; details only when useful."""
    started = time.monotonic()
    lines: List[str] = []
    proc = subprocess.Popen(argv, env=ctx.env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors="replace", bufsize=1)
    with Spinner(ctx.ui, step.name) as spinner:
        reader = threading.Thread(target=_pump, args=(proc, lines, spinner, ctx), daemon=True)
        reader.start()
        code = proc.wait()
        reader.join()
    status = _status(code, ctx.dry_run)
    result = Result(step.name, status, time.monotonic() - started, _note(lines, status))
    ctx.ui.step_result(step.name, step.summary, status, result.seconds, result.note)
    _show_details(ctx, lines, status)
    return result


def _pump(proc: subprocess.Popen, lines: List[str], spinner: Spinner, ctx: Context) -> None:
    assert proc.stdout is not None
    for line in proc.stdout:
        lines.append(line)
        spinner.update(line)
        _log(ctx, line)


def _show_details(ctx: Context, lines: List[str], status: str) -> None:
    if status == "failed":
        ctx.ui.detail(lines[-TAIL_ON_FAILURE:], "red")
    elif ctx.verbose or ctx.dry_run:
        ctx.ui.detail(lines)
    else:  # warnings are always worth seeing
        ctx.ui.detail([line for line in lines if strip_ansi(line).lstrip().startswith("!")], "yellow")


def _stream(ctx: Context, step: Step, argv: List[str]) -> Result:
    """Non-TTY (CI) or interactive steps: the step talks to the terminal directly."""
    ctx.ui.step_header(step.name, step.summary)
    started = time.monotonic()
    code = subprocess.call(argv, env=ctx.env)
    status = _status(code, ctx.dry_run)
    result = Result(step.name, status, time.monotonic() - started)
    ctx.ui.step_result(step.name, step.summary, status, result.seconds)
    return result


def run_step(ctx: Context, step: Step) -> Result:
    script = ctx.root / "install.d" / step.script_for(ctx.host)
    if not script.is_file():
        return Result(step.name, "failed", 0.0, "missing " + str(script))
    argv = ["bash", str(script)]
    _log(ctx, "\n==== %s (%s) ====\n" % (step.name, script.name))
    interactive = step.is_interactive(ctx.host) and ctx.ui.tty
    if ctx.ui.tty and not interactive and not ctx.verbose:
        return _capture(ctx, step, argv)
    return _stream(ctx, step, argv)


def step_env(root: Path, host: Host, profile: str, extra: str, without: str, dry_run: bool, no_sudo: bool) -> Dict[str, str]:
    env = dict(os.environ)
    env.update(
        DOTFILES=str(root),
        OS=host.os,
        PROFILE=profile,
        WITH=extra,
        WITHOUT=without,
        DRY_RUN="1" if dry_run else "0",
        NO_SUDO="1" if no_sudo else "0",
        LOCAL_PREFIX=env.get("LOCAL_PREFIX", str(Path.home() / ".local")),
        UV_NO_MODIFY_PATH="1",  # third-party installers must not edit ~/.zshrc (a repo symlink)
    )
    return env
