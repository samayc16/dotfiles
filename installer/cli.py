"""Command line: parse flags, show the plan, run the steps, print the summary."""

from __future__ import annotations

import argparse
import sys
import time
from contextlib import contextmanager
from pathlib import Path
from typing import FrozenSet, Iterator, List, Optional, Sequence, TextIO

from . import host as host_mod
from .runner import Context, Result, run_step, step_env
from .steps import PROFILE_HELP, PROFILES, Selection, plan, unknown_names
from .ui import Ui

# Sub-components understood by the step scripts (install.d/lib.sh `wants`)
COMPONENTS = frozenset({"devtools", "lazy", "bootstrap", "hdl-src"})

EPILOG = """profiles:
%s

examples:
  ./install.sh                         everything (profile full)
  ./install.sh --profile cli           minimal: shell, tmux, nvim, CLI tools
  ./install.sh --no-sudo               no root: everything user-local in ~/.local
  ./install.sh --only nvim,smoke       re-run just those steps
  ./install.sh --skip games,learn      everything except those
  ./install.sh --without hdl-src       never build Verilator/Icarus from source
  ./install.sh --dry-run               print what would run
""" % "\n".join("  %-5s %s" % (name, PROFILE_HELP[name]) for name in PROFILES)


def _names(value: str) -> FrozenSet[str]:
    return frozenset(part.strip() for part in value.split(",") if part.strip())


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="install.sh",
        description="Install these dotfiles on macOS or Linux (Arch, Debian/Ubuntu, Fedora/RHEL, openSUSE).",
        epilog=EPILOG,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--profile", choices=PROFILES, default="full", help="how much to install (default: full)")
    parser.add_argument("--with", dest="extra", type=_names, default=frozenset(), metavar="A,B", help="add steps/components beyond the profile")
    parser.add_argument("--without", "--skip", dest="skip", type=_names, default=frozenset(), metavar="A,B", help="leave out steps/components")
    parser.add_argument("--only", type=_names, default=frozenset(), metavar="A,B", help="run only these steps")
    parser.add_argument("--link-only", action="store_true", help="just (re)create the symlinks (same as --only links)")
    parser.add_argument("--no-sudo", action="store_true", help="never use sudo/root; install everything user-locally")
    parser.add_argument("--dry-run", action="store_true", help="print commands instead of running them")
    parser.add_argument("--list-steps", action="store_true", help="show the steps and whether they'd run, then exit")
    parser.add_argument("-v", "--verbose", action="store_true", help="stream every step's full output")
    parser.add_argument("--no-log", action="store_true", help="don't write a log file")
    args = parser.parse_args(argv)
    if args.link_only:
        args.only = frozenset({"links"})
    bad = unknown_names(args.extra | args.skip | args.only, COMPONENTS)
    if bad:
        parser.error("unknown step/component: %s (see --list-steps)" % ", ".join(bad))
    return args


def _facts(host: host_mod.Host, args: argparse.Namespace) -> List[str]:
    if host.is_mac:
        privilege = "Homebrew"
    elif host.is_root:
        privilege = "root"
    elif host.can_sudo:
        privilege = "sudo"
    else:
        privilege = "no sudo → user-local only"
    facts = ["%s (%s)" % (host.distro, host.arch), "profile " + args.profile, privilege]
    if host.wsl:
        facts.append("WSL")
    if args.dry_run:
        facts.append("dry run")
    return facts


def list_steps(ui: Ui, host: host_mod.Host, selection: Selection) -> None:
    for step, reason in plan(host, selection):
        marker = ui.paint("●", "green") if not reason else ui.paint("○", "gray")
        detail = step.summary if not reason else ui.paint("%s — %s" % (step.summary, reason), dim=True)
        ui.line("  %s %-9s %s" % (marker, step.name, detail))
    ui.line()
    ui.line(ui.paint("  components (for --with/--without): " + ", ".join(sorted(COMPONENTS)), dim=True))


@contextmanager
def open_log(disabled: bool) -> Iterator[Optional[TextIO]]:
    if disabled:
        yield None
        return
    log_dir = Path.home() / ".cache" / "dotfiles"
    log_dir.mkdir(parents=True, exist_ok=True)
    path = log_dir / time.strftime("install-%Y%m%d-%H%M%S.log")
    with path.open("w", encoding="utf-8") as handle:
        yield handle


def run_plan(ctx: Context, selection: Selection) -> List[Result]:
    results = []
    for step, reason in plan(ctx.host, selection):
        if reason:
            if not selection.only or step.name in selection.only:
                ctx.ui.step_result(step.name, step.summary, "skipped", 0.0, reason)
            results.append(Result(step.name, "skipped", 0.0, reason))
            continue
        results.append(run_step(ctx, step))
    return results


def main(argv: Optional[Sequence[str]] = None, root: Optional[Path] = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    root = root or Path(__file__).resolve().parent.parent
    ui = Ui()
    host = host_mod.detect(no_sudo=args.no_sudo)
    selection = Selection(args.profile, args.only, args.skip, args.extra)
    ui.banner("dotfiles", _facts(host, args))
    if args.list_steps:
        list_steps(ui, host, selection)
        return 0
    env = step_env(root, host, args.profile, ",".join(sorted(args.extra)), ",".join(sorted(args.skip)), args.dry_run, args.no_sudo)
    with open_log(args.no_log or args.dry_run) as log:
        ctx = Context(root, host, env, ui, log, args.dry_run, args.verbose)
        try:
            results = run_plan(ctx, selection)
        except KeyboardInterrupt:
            ui.line()
            ui.line(ui.paint("  interrupted", "red", bold=True))
            return 130
        ran = [r for r in results if not (selection.only and r.name not in selection.only)]
        ui.summary(ran, log.name if log else None)
    return 1 if any(r.status == "failed" for r in results) else 0
