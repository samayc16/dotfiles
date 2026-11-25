#!/usr/bin/env python3
"""Keep pins.txt current: every external version the installer uses.

  scripts/bump-pins.py bump [--pins FILE] [--changes FILE]   move each pin to the newest version
  scripts/bump-pins.py diff OLD NEW                          what changed between two pins files
  scripts/bump-pins.py table [--pins FILE]                   name and version of every pin
  scripts/bump-pins.py asset NAME PATTERN [--pins FILE]      download URL of a pinned release's asset

Newest means `git ls-remote <url> HEAD` for a commit pin, and GitHub's releases/latest for a
release pin (GITHUB_TOKEN is used when set). Only numbered tags (v1.2.3) count as releases; with
none yet, or when a lookup fails, the pin stays where it is and a warning says why.
Standard library only, Python 3.8+.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Callable, List, Optional, Sequence, Tuple, Union

ROOT = Path(__file__).resolve().parent.parent
KINDS = ("commit", "release")
NONE = "-"  # a release pin with no numbered release yet
NUMBERED = re.compile(r"^v?\d+(\.\d+)*$")
GITHUB = re.compile(r"^https://github\.com/([^/\s]+/[^/\s]+?)(?:\.git)?/?$")
HEADER = ("#", "name", "kind", "source", "version")
TIMEOUT = 30


class PinError(Exception):
    """A pins file that doesn't parse, or a lookup that failed."""


@dataclass(frozen=True)
class Pin:
    name: str
    kind: str
    source: str
    version: str


Line = Union[str, Pin]  # comments and blank lines are kept verbatim


@dataclass(frozen=True)
class Change:
    name: str
    old: str
    new: str

    def __str__(self) -> str:
        return "%s: %s → %s" % (self.name, short(self.old), short(self.new))


def short(version: str) -> str:
    return version[:12] if re.fullmatch(r"[0-9a-f]{40}", version) else version


# ── pins.txt ──────────────────────────────────────────────────────────


def parse(text: str) -> List[Line]:
    lines: List[Line] = []
    seen = set()
    for number, raw in enumerate(text.splitlines(), 1):
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            lines.append(raw.rstrip())
            continue
        fields = stripped.split()
        if len(fields) != 4:
            raise PinError("line %d: expected `name kind source version`, got %r" % (number, stripped))
        pin = Pin(*fields)
        if pin.kind not in KINDS:
            raise PinError("line %d: kind must be one of %s, got %r" % (number, ", ".join(KINDS), pin.kind))
        if pin.name in seen:
            raise PinError("line %d: %s is pinned twice" % (number, pin.name))
        seen.add(pin.name)
        lines.append(pin)
    return lines


def pins_of(lines: Sequence[Line]) -> List[Pin]:
    return [line for line in lines if isinstance(line, Pin)]


def render(lines: Sequence[Line]) -> str:
    """Pins in aligned columns; comments as they were, except the column header, realigned."""
    pins = pins_of(lines)
    widths = [max([len(getattr(pin, field)) for pin in pins] + [len(title)]) for field, title in (("name", "# name"), ("kind", "kind"), ("source", "source"))]

    def row(cells: Sequence[str]) -> str:
        return "  ".join(cell.ljust(width) for cell, width in zip(cells, widths)) + "  " + cells[3]

    out = []
    for line in lines:
        if isinstance(line, Pin):
            out.append(row((line.name, line.kind, line.source, line.version)))
        elif tuple(line.split()) == HEADER:
            out.append(row(("# name", "kind", "source", "version")))
        else:
            out.append(line)
    return "\n".join(out) + "\n"


def load(path: Path) -> List[Line]:
    try:
        return parse(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise PinError("cannot read %s: %s" % (path, exc)) from exc


# ── upstream lookups ──────────────────────────────────────────────────


def git_head(url: str) -> str:
    """The commit at the default branch's tip."""
    try:
        out = subprocess.run(["git", "ls-remote", url, "HEAD"], capture_output=True, text=True, timeout=TIMEOUT, check=True).stdout
    except (OSError, subprocess.SubprocessError) as exc:
        raise PinError("git ls-remote %s failed: %s" % (url, getattr(exc, "stderr", "") or exc)) from exc
    for line in out.splitlines():
        sha, _, ref = line.partition("\t")
        if ref == "HEAD" and re.fullmatch(r"[0-9a-f]{40}", sha):
            return sha
    raise PinError("git ls-remote %s: no HEAD" % url)


def github_repo(source: str) -> str:
    match = GITHUB.match(source)
    if not match:
        raise PinError("not a GitHub repo URL: %s" % source)
    return match.group(1)


def github_api(path: str, token: Optional[str]) -> Optional[dict]:
    """GET api.github.com/<path> as JSON; None on 404."""
    request = urllib.request.Request("https://api.github.com/" + path, headers={"Accept": "application/vnd.github+json", "User-Agent": "dotfiles-bump-pins"})
    if token:
        request.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            return json.load(response)
    except urllib.error.HTTPError as exc:
        exc.close()
        if exc.code == 404:
            return None
        raise PinError("GitHub API %s: HTTP %d" % (path, exc.code)) from exc
    except (OSError, ValueError) as exc:
        raise PinError("GitHub API %s: %s" % (path, exc)) from exc


def latest_release(source: str, token: Optional[str] = None) -> Optional[str]:
    """Tag of the newest numbered release, or None when there isn't one."""
    release = github_api("repos/%s/releases/latest" % github_repo(source), token)
    tag = (release or {}).get("tag_name", "")
    return tag if NUMBERED.match(tag) else None


# ── commands ──────────────────────────────────────────────────────────

Lookup = Callable[[str], Optional[str]]


def bump(lines: Sequence[Line], head: Lookup, release: Lookup) -> Tuple[List[Line], List[Change], List[str]]:
    """Each pin moved to the newest version: (new lines, what changed, warnings)."""
    changes: List[Change] = []
    warnings: List[str] = []
    out: List[Line] = []
    for line in lines:
        if not isinstance(line, Pin):
            out.append(line)
            continue
        try:
            newest = head(line.source) if line.kind == "commit" else release(line.source)
        except PinError as exc:
            warnings.append("%s: kept %s (%s)" % (line.name, short(line.version), exc))
            newest = None
        if newest is None and line.kind == "release":
            warnings.append("%s: no numbered release yet, kept %s" % (line.name, line.version))
        if newest and newest != line.version:
            changes.append(Change(line.name, line.version, newest))
            line = replace(line, version=newest)
        out.append(line)
    return out, changes, warnings


def diff(old: Sequence[Line], new: Sequence[Line]) -> List[Change]:
    before = {pin.name: pin.version for pin in pins_of(old)}
    changes = [Change(pin.name, before.get(pin.name, "(new)"), pin.version) for pin in pins_of(new) if before.get(pin.name) != pin.version]
    after = {pin.name for pin in pins_of(new)}
    return changes + [Change(name, version, "(removed)") for name, version in before.items() if name not in after]


def table(lines: Sequence[Line]) -> str:
    pins = pins_of(lines)
    width = max(len(pin.name) for pin in pins)
    return "".join("%s  %s\n" % (pin.name.ljust(width), pin.version) for pin in pins)


def asset_url(lines: Sequence[Line], name: str, pattern: str, token: Optional[str]) -> str:
    pin = next((pin for pin in pins_of(lines) if pin.name == name), None)
    if pin is None or pin.kind != "release":
        raise PinError("%s is not a release pin" % name)
    if pin.version == NONE:
        raise PinError("%s has no release pinned yet" % name)
    release = github_api("repos/%s/releases/tags/%s" % (github_repo(pin.source), pin.version), token)
    for asset in (release or {}).get("assets", []):
        if fnmatch.fnmatch(asset.get("name", ""), pattern):
            return asset["browser_download_url"]
    raise PinError("%s %s has no asset matching %s" % (name, pin.version, pattern))


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(prog="bump-pins.py", description=__doc__.split("\n\n")[0])
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("bump", "table", "asset"):
        command = sub.add_parser(name)
        command.add_argument("--pins", type=Path, default=ROOT / "pins.txt")
        if name == "bump":
            command.add_argument("--changes", type=Path, help="also write the change list here")
        if name == "asset":
            command.add_argument("name")
            command.add_argument("pattern")
    compare = sub.add_parser("diff")
    compare.add_argument("old", type=Path)
    compare.add_argument("new", type=Path)
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None, head: Lookup = git_head, release: Optional[Lookup] = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    token = os.environ.get("GITHUB_TOKEN") or None
    try:
        if args.command == "bump":
            lines, changes, warnings = bump(load(args.pins), head, release or (lambda source: latest_release(source, token)))
            for warning in warnings:
                print("warning: " + warning, file=sys.stderr)
            args.pins.write_text(render(lines), encoding="utf-8")
            report = "".join("%s\n" % change for change in changes)
            if args.changes:
                args.changes.write_text(report, encoding="utf-8")
            print(report or "every pin is already the newest", end="" if report else "\n")
        elif args.command == "diff":
            print("".join("%s\n" % change for change in diff(load(args.old), load(args.new))), end="")
        elif args.command == "table":
            print(table(load(args.pins)), end="")
        else:
            print(asset_url(load(args.pins), args.name, args.pattern, token))
    except PinError as exc:
        print("bump-pins: %s" % exc, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
