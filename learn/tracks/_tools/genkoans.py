"""Generate a koans track (shared exercise format) from a single-source definition.

Koan code is written once, as the reference solution, with marked blocks:

    #>> starter line(s) shown to the learner     (or //>> for C-family/Swift)
    solution line(s)
    #<<                                           (or //<<)

The starter keeps the `>>` lines (marker stripped, indentation kept); the solution
keeps everything else. One source means starter and solution can't drift apart.

Usage: python3 genkoans.py <definition.py> <output track dir>
A definition module exposes TRACK (dict) and KOANS (list of dicts with keys:
slug, title, difficulty, xp, concepts, hints, why, task, code, test, file, test_file).
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


def readme(koan: dict, track: dict, number: int) -> str:
    keys = track["nvim_tips"]
    return (
        f"# {number:02d} · {koan['title']}\n\n"
        f"## Why it matters\n{koan['why'].strip()}\n\n"
        f"## Your task\n{koan['task'].strip()}\n\n"
        f"Edit `{koan.get('file', track['file'])}` until every check passes.\n\n"
        f"## Run it\n- `learn check` in a terminal, or `<leader>lc` in nvim\n"
        f"- Stuck? `learn hint` / `<leader>lh` (costs ★★)\n\n"
        f"## Nvim tips\n{keys}\n"
    )


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
        file_name = koan.get("file", track["file"])
        starter, solution = split_variants(koan["code"])
        (ex / file_name).write_text(starter)
        (ex / "solution" / file_name).write_text(solution)
        (ex / koan.get("test_file", track["test_file"])).write_text(koan["test"].strip("\n") + "\n")
        (ex / "README.md").write_text(readme(koan, track, number))
        check = ex / "check.sh"
        check.write_text(f'#!/usr/bin/env bash\nexec bash "$LEARN_EXERCISE_DIR/../_lib/{track["checker"]}"\n')
        check.chmod(0o755)
        meta = {
            "title": koan["title"],
            "difficulty": koan["difficulty"],
            "xp": koan["xp"],
            "concepts": koan["concepts"],
            "files": [file_name],
            "open": file_name,
            "check": "check.sh",
            "hints": koan["hints"],
        }
        (ex / "exercise.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False) + "\n")
    track_meta = {k: track[k] for k in ("name", "slug", "language", "description")}
    (out_dir / "track.json").write_text(json.dumps({**track_meta, "order": order}, indent=2) + "\n")
    print(f"wrote {len(koans)} koans to {out_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
