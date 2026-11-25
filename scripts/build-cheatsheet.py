#!/usr/bin/env python3
"""Build CHEATSHEET.md from cheatsheets/*.md: one page per app, and one page with them all.

  scripts/build-cheatsheet.py           rewrite CHEATSHEET.md
  scripts/build-cheatsheet.py --check   exit 1 if CHEATSHEET.md is out of date (CI runs this)

Edit the files in cheatsheets/, never CHEATSHEET.md. Each app's headings move down one level
on the combined page, and links relative to cheatsheets/ are made relative to the repo root.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import List, Tuple

ROOT = Path(__file__).resolve().parents[1]
SHEETS = ROOT / "cheatsheets"
OUT = ROOT / "CHEATSHEET.md"

# The order on the combined page. A sheet missing from here is an error, not silently dropped.
ORDER = ("dotfiles", "shell", "tmux", "neovim", "learn", "tamp", "kitty", "git", "claude", "codex")

HEADER = """\
<!-- Generated from cheatsheets/*.md by scripts/build-cheatsheet.py: edit those, then run it. -->
# cheatsheet

Everything wired up by this repo, grouped by tool. One app at a time: the files in [cheatsheets/](cheatsheets/), \
`cheat <app>` in a terminal (`cheat <words>` searches every app), `:Cheat` in Neovim, `prefix ?` in tmux.
"""

FENCE = re.compile(r"^\s*(```|~~~)")
HEADING = re.compile(r"^(#{1,5}) ")
RELATIVE_LINK = re.compile(r"(\]\()\.\./")


def sheets(directory: Path = SHEETS) -> List[Tuple[str, str]]:
    found = {p.stem for p in directory.glob("*.md")}
    missing = [name for name in ORDER if name not in found]
    unlisted = sorted(found - set(ORDER))
    if missing or unlisted:
        problems = [f"no cheatsheets/{n}.md" for n in missing] + [f"cheatsheets/{n}.md is not in ORDER" for n in unlisted]
        raise SystemExit("build-cheatsheet: " + "; ".join(problems))
    return [(name, (directory / f"{name}.md").read_text()) for name in ORDER]


def title(text: str) -> str:
    for line in text.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    raise SystemExit("build-cheatsheet: a sheet has no '# title' line")


def slug(heading: str) -> str:
    """GitHub's anchor for a heading: lower case, punctuation dropped, spaces become hyphens."""
    return re.sub(r"[^\w\- ]", "", heading.lower()).replace(" ", "-")


def demote(text: str) -> str:
    """One heading level down (# → ##), leaving fenced code alone."""
    out, fenced = [], False
    for line in text.splitlines():
        if FENCE.match(line):
            fenced = not fenced
        elif not fenced and HEADING.match(line):
            line = "#" + line
        out.append(line)
    return "\n".join(out)


def build(directory: Path = SHEETS) -> str:
    parts = sheets(directory)
    contents = " · ".join(f"[{name}](#{slug(title(text))})" for name, text in parts)
    bodies = [RELATIVE_LINK.sub(r"\1", demote(text)).strip() for _, text in parts]
    return HEADER + "\n" + contents + "\n\n" + "\n\n---\n\n".join(bodies) + "\n"


def main(argv: List[str]) -> int:
    if argv not in ([], ["--check"]):
        print(__doc__.strip(), file=sys.stderr)
        return 2
    text = build()
    if argv == ["--check"]:
        if OUT.read_text() != text:
            print("CHEATSHEET.md is out of date: run scripts/build-cheatsheet.py", file=sys.stderr)
            return 1
        return 0
    OUT.write_text(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
