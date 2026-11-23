"""Generate a koans track (shared exercise format) from a single-source definition.

Koan code is written once, as the reference solution, with marked blocks:

    #>> starter line(s) shown to the learner     (or //>> for C-family/Swift)
    solution line(s)
    #<<                                           (or //<<)

The starter keeps the `>>` lines (marker stripped, indentation kept); the solution
keeps everything else. One source means starter and solution can't drift apart.

Usage: python3 genkoans.py <definition.py> <output track dir>
A definition module exposes TRACK (dict) and KOANS (list of dicts with keys:
slug, title, difficulty, xp, concepts, hints, why, task, code, test, file, test_file,
and optionally primer / syntax: see optional_sections).

Optional, for project-shaped koans (Rust/Cargo):
  sources       {path: code} instead of code/file: several learner files, the first is opened
  extra_files   {path: text} written as-is into the exercise dir (e.g. a Cargo.toml)
  support       read-only files the workspace gets a fresh copy of (koan, else TRACK key)
  run_tips      TRACK key: extra bullet(s) for the README's "Run it" section
  starter_compiles=False   the starter's compile error is the lesson (read by _verify.sh)
"""

from __future__ import annotations

import importlib.util
import json
import re
import shutil
import sys
from pathlib import Path

MARK = re.compile(r"^(\s*)(?:#|//|--)(>>|<<)(?: ?(.*))?$")


def split_variants(code: str) -> tuple[str, str]:
    starter: list[str] = []
    solution: list[str] = []
    in_block = False
    for line in code.strip("\n").splitlines():
        m = MARK.match(line)
        if m and m.group(2) == ">>":
            in_block = True
            starter.append(m.group(1) + (m.group(3) or ""))
        elif m and m.group(2) == "<<":
            in_block = False
        elif in_block:
            solution.append(line)
        else:
            starter.append(line)
            solution.append(line)
    if in_block:
        raise ValueError("unterminated >> block")
    return "\n".join(starter) + "\n", "\n".join(solution) + "\n"


def optional_sections(koan: dict) -> str:
    """Beginner scaffolding, both optional: `primer` (markdown that brings its own `## ...`
    heading, used on a track's first koan) and `syntax` (body of a `## New syntax` section)."""
    parts = []
    if koan.get("primer"):
        parts.append(f"{koan['primer'].strip()}\n\n")
    if koan.get("syntax"):
        parts.append(f"## New syntax\n{koan['syntax'].strip()}\n\n")
    return "".join(parts)


def sources(koan: dict, track: dict) -> dict:
    """{learner file: marked code}; the first file is the one the exercise opens."""
    return koan.get("sources") or {koan.get("file", track["file"]): koan["code"]}


def readme(koan: dict, track: dict, number: int) -> str:
    keys = track["nvim_tips"]
    edit = " and ".join(f"`{name}`" for name in sources(koan, track))
    run_tips = f"{track['run_tips'].strip()}\n" if track.get("run_tips") else ""
    return (
        f"# {number:02d} · {koan['title']}\n\n"
        f"## Why it matters\n{koan['why'].strip()}\n\n"
        f"{optional_sections(koan)}"
        f"## Your task\n{koan['task'].strip()}\n\n"
        f"Edit {edit} until every check passes.\n\n"
        f"## Run it\n- `learn check` in a terminal, or `<leader>lc` in nvim\n"
        f"- Stuck? `learn hint` / `<leader>lh` (costs ★★)\n{run_tips}\n"
        f"## Nvim tips\n{keys}\n"
    )


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def main() -> int:
    definition, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    spec = importlib.util.spec_from_file_location("koandef", definition)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    track, koans = module.TRACK, module.KOANS
    out_dir.mkdir(parents=True, exist_ok=True)
    order = []
    for number, koan in enumerate(koans, start=1):
        name = f"{number:02d}-{koan['slug']}"
        order.append(name)
        ex = out_dir / name
        if ex.exists():
            shutil.rmtree(ex)
        (ex / "solution").mkdir(parents=True)
        files = sources(koan, track)
        for file_name, code in files.items():
            starter, solution = split_variants(code)
            write(ex / file_name, starter)
            write(ex / "solution" / file_name, solution)
        for file_name, text in koan.get("extra_files", {}).items():
            write(ex / file_name, text)
        write(ex / koan.get("test_file", track["test_file"]), koan["test"].strip("\n") + "\n")
        (ex / "README.md").write_text(readme(koan, track, number))
        check = ex / "check.sh"
        check.write_text(f'#!/usr/bin/env bash\nexec bash "$LEARN_EXERCISE_DIR/../_lib/{track["checker"]}"\n')
        check.chmod(0o755)
        meta = {
            "title": koan["title"],
            "difficulty": koan["difficulty"],
            "xp": koan["xp"],
            "concepts": koan["concepts"],
            "files": list(files),
            "open": next(iter(files)),
            "check": "check.sh",
            "hints": koan["hints"],
        }
        support = koan.get("support", track.get("support"))
        if support:
            meta["support"] = list(support)
        if koan.get("starter_compiles") is False:
            meta["starter_compiles"] = False
        (ex / "exercise.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False) + "\n")
    track_meta = {k: track[k] for k in ("name", "slug", "language", "description")}
    (out_dir / "track.json").write_text(json.dumps({**track_meta, "order": order}, indent=2) + "\n")
    print(f"wrote {len(koans)} koans to {out_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
