"""`learn` command-line interface."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

from . import docs as docs_mod
from . import exercism, progress, scoring, ui, workspace
from . import tracks as tracks_mod
from .model import Exercise, Track

FRONTIER = 3  # how many unpassed exercises are open at once in a track
CHECK_TIMEOUT_S = 900
DIFFICULTY = {
    1: ("easy", "green"),
    2: ("easy+", "green"),
    3: ("medium", "yellow"),
    4: ("hard", "orange"),
    5: ("boss", "red"),
}


# ── helpers ──────────────────────────────────────────────────────────────────


def _passed_count(track: Track, data: dict) -> int:
    return sum(1 for ex in track.exercises if progress.entry(data, ex.key)["passed"])


def is_unlocked(track: Track, index: int, data: dict) -> bool:
    entry = progress.entry(data, track.exercises[index].key)
    return entry["passed"] or entry["attempts"] > 0 or index < _passed_count(track, data) + FRONTIER


def next_in_track(track: Track, data: dict) -> Exercise | None:
    for i, ex in enumerate(track.exercises):
        if not progress.entry(data, ex.key)["passed"] and is_unlocked(track, i, data):
            return ex
    return None


def _current_exercise(all_tracks: tuple[Track, ...], key: str | None) -> Exercise:
    key = key or workspace.read_marker(Path.cwd())
    if not key:
        raise SystemExit(
            ui.paint("✗", "red") + " Not inside a learn workspace. Use `learn start <track>/<slug>` or `learn next`."
        )
    exercise = tracks_mod.resolve(all_tracks, key)
    if exercise is None:
        raise SystemExit(ui.paint("✗", "red") + f" Unknown exercise {key!r}. Try `learn tracks`.")
    return exercise


def _ordered_files(exercise: Exercise) -> list[str]:
    return [exercise.open, *[f for f in exercise.files if f != exercise.open]]


def _launch_payload(exercise: Exercise, ws: Path) -> dict:
    return {
        "key": exercise.key,
        "title": exercise.title,
        "workspace": str(ws),
        "open": exercise.open,
        "files": _ordered_files(exercise),
        "readme": "README.md",
    }


def _exec_nvim(exercise: Exercise, ws: Path) -> None:
    nvim = shutil.which("nvim")
    if nvim is None:
        ui.info(f"Workspace ready: {ws}")
        return
    os.chdir(ws)
    files = _ordered_files(exercise)
    os.execv(nvim, [nvim, *files, "-c", "vertical botright split README.md | wincmd p"])


def _level_line(data: dict) -> str:
    xp = progress.total_xp(data)
    level = scoring.level_for(xp)
    low, high = scoring.level_bounds(level)
    streak = progress.streak(data)
    fire = ui.paint(f"🔥 {streak}-day streak", "orange") if streak else ui.dim("no streak yet: pass something today")
    return (
        f" {ui.paint('Level ' + str(level), 'purple', bold=True)} · {ui.paint(scoring.title_for(level), 'cyan')}"
        f"   {ui.paint(str(xp) + ' XP', 'yellow', bold=True)} {ui.bar(xp - low, high - low, 20, 'purple')}"
        f" {ui.dim(str(high) + ' for next')}   {fire}"
    )


# ── commands ─────────────────────────────────────────────────────────────────


def cmd_dashboard(all_tracks: tuple[Track, ...], data: dict) -> int:
    print(ui.paint(" learn", "green", bold=True) + ui.dim("  ·  offline training for your editor, shell and languages"))
    print(ui.rule(78))
    print(_level_line(data))
    print()
    for track in all_tracks:
        total = len(track.exercises)
        passed = _passed_count(track, data)
        got = sum(progress.entry(data, ex.key)["stars"] for ex in track.exercises)
        print(
            f" {track.name[:30]:<30} {ui.bar(passed, total, 18)} {passed:>3}/{total:<4}"
            f" {ui.paint('★', 'yellow')} {got}/{total * 3}"
        )
    print()
    last = data.get("last")
    suggestion = None
    if last and "/" in last:
        track = tracks_mod.find_track(all_tracks, last.split("/", 1)[0])
        suggestion = next_in_track(track, data) if track else None
    suggestion = suggestion or next((ex for t in all_tracks if (ex := next_in_track(t, data))), None)
    if suggestion:
        print(f" Next up: {ui.paint(suggestion.key, 'cyan', bold=True)}  {suggestion.title}")
        print(ui.dim(f"          learn next {suggestion.track}   ·   in nvim: <leader>ln  ·  pick: <leader>ll"))
    print(ui.dim(" Neovim motions/config drills live in nvim: :Dojo"))
    return 0


def cmd_tracks(all_tracks: tuple[Track, ...], data: dict) -> int:
    for track in all_tracks:
        passed = _passed_count(track, data)
        print(f" {ui.paint(track.slug, 'cyan', bold=True):<28} {passed:>3}/{len(track.exercises):<4} {track.name}")
        if track.description:
            print(ui.dim(f"     {track.description}"))
    return 0


def cmd_list(all_tracks: tuple[Track, ...], data: dict, slug: str, show_all: bool) -> int:
    track = tracks_mod.find_track(all_tracks, slug)
    if track is None:
        ui.error(f"no track {slug!r}. Available: {', '.join(t.slug for t in all_tracks)}")
        return 2
    print(ui.paint(f" {track.name}", "green", bold=True) + ui.dim(f"  ({track.slug})"))
    print(ui.rule(78))
    hidden = 0
    for i, ex in enumerate(track.exercises):
        entry = progress.entry(data, ex.key)
        unlocked = is_unlocked(track, i, data)
        if not unlocked and not show_all:
            hidden += 1
            continue
        label, color = DIFFICULTY.get(ex.difficulty, ("?", "gray"))
        mark = ui.stars(entry["stars"]) if entry["passed"] else (ui.dim(" 🔒") + " " if not unlocked else ui.dim("···"))
        concepts = ui.dim(", ".join(ex.concepts[:3]))
        print(f" {i + 1:>3}  {mark}  {ex.title[:34]:<34} {ui.paint(label, color):<8} {concepts}")
    if hidden:
        print(ui.dim(f"  … {hidden} more locked. Pass exercises to unlock, or `learn list {slug} --all`."))
    return 0


def cmd_start(all_tracks: tuple[Track, ...], data: dict, key: str, as_json: bool, force: bool) -> int:
    exercise = tracks_mod.resolve(all_tracks, key)
    if exercise is None:
        ui.error(f"unknown exercise {key!r}. Use `learn list <track>` to see slugs.")
        return 2
    track = tracks_mod.find_track(all_tracks, exercise.track)
    index = track.index_of(exercise.slug) if track else 0
    if track and not is_unlocked(track, index, data) and not force:
        ui.warn(f"{key} is locked. Pass earlier exercises first, or add --force.")
        return 3
    ws = workspace.prepare(exercise)
    if as_json:
        print(json.dumps(_launch_payload(exercise, ws)))
        return 0
    ui.info(f"{ui.paint(exercise.title, 'cyan', bold=True)}  →  {ws}")
    _exec_nvim(exercise, ws)
    return 0


def cmd_next(all_tracks: tuple[Track, ...], data: dict, slug: str | None, as_json: bool) -> int:
    candidates = [t for t in all_tracks if t.slug == slug] if slug else []
    if slug and not candidates:
        ui.error(f"no track {slug!r}")
        return 2
    if not candidates:
        current = workspace.read_marker(Path.cwd()) or data.get("last") or ""
        preferred = current.split("/", 1)[0]
        candidates = sorted(all_tracks, key=lambda t: t.slug != preferred)
    for track in candidates:
        exercise = next_in_track(track, data)
        if exercise:
            return cmd_start(all_tracks, data, exercise.key, as_json, force=True)
    ui.info(ui.paint("Everything here is passed. Legendary. 🏆", "yellow", bold=True))
    return 0


def cmd_prev(all_tracks: tuple[Track, ...], data: dict, slug: str | None, as_json: bool) -> int:
    """Open the exercise before the current one: the workspace you're in, else the one
    `learn next` would open (in `slug`, or the track you were last working in)."""
    current = workspace.read_marker(Path.cwd()) or ""
    slug = slug or (current or data.get("last") or "").split("/", 1)[0]
    track = tracks_mod.find_track(all_tracks, slug) if slug else None
    if track is None:
        ui.error(f"no track {slug!r}" if slug else "nothing to go back from yet: open one with `learn next`.")
        return 2
    if current.startswith(track.slug + "/"):
        index = track.index_of(current.split("/", 1)[1])
    else:
        upcoming = next_in_track(track, data)
        index = track.index_of(upcoming.slug) if upcoming else len(track.exercises)
    if index <= 0:
        ui.info(f"{track.exercises[0].title} is the first exercise in {track.name}.")
        return 0
    return cmd_start(all_tracks, data, track.exercises[index - 1].key, as_json, force=True)


def _run_check(exercise: Exercise, ws: Path) -> int:
    env = {**os.environ, "LEARN_EXERCISE_DIR": str(exercise.source_dir), "LEARN_WORKSPACE": str(ws)}
    if exercise.kind == "exercism":
        cmd, extra_env = exercism.test_command(exercise, workspace.VENV_DIR / "bin" / "python")
        env.update(extra_env)
    else:
        cmd = ["bash", str(exercise.source_dir / exercise.extra["check"])]
    try:
        return subprocess.run(cmd, cwd=ws, env=env, timeout=CHECK_TIMEOUT_S).returncode
    except FileNotFoundError as exc:
        ui.error(f"could not run {cmd[0]!r}: {exc}. Is the toolchain installed? (learn/fetch.sh)")
        return 127
    except subprocess.TimeoutExpired:
        ui.error(f"check timed out after {CHECK_TIMEOUT_S}s (infinite loop?)")
        return 124


def _celebrate(exercise: Exercise, before: dict, after: dict, old_xp: int, new_xp: int, length: int | None) -> None:
    gained = new_xp - old_xp
    lines = [f"PASSED  {exercise.title}", f"{ui.stars(after['stars'])}   +{gained} XP"]
    if exercise.par is not None and length is not None:
        verdict = "within par ⛳" if length <= exercise.par else f"par is {exercise.par}: golf it for ★★★"
        lines.append(f"solution length {length} · {verdict}")
    if after["stars"] < 3 and before["stars"] < 3:
        lines.append("retry without hints for more stars")
    print(ui.banner(lines, "green"))
    old_level, new_level = scoring.level_for(old_xp), scoring.level_for(new_xp)
    if new_level > old_level:
        print(ui.paint(f" ⬆  LEVEL UP: {new_level} · {scoring.title_for(new_level)}", "purple", bold=True))


def cmd_check(all_tracks: tuple[Track, ...], data: dict, key: str | None) -> int:
    exercise = _current_exercise(all_tracks, key)
    ws = workspace.prepare(exercise)
    ui.info(f"checking {ui.paint(exercise.key, 'cyan')} …")
    code = _run_check(exercise, ws)
    before = progress.entry(data, exercise.key)
    attempts = before["attempts"] + 1
    data = progress.touch_today(data)
    if code != 0:
        progress.save(progress.with_entry(data, exercise.key, {**before, "attempts": attempts}))
        left = len(exercise.hints) - before["hints_used"]
        tip = f"`learn hint` ({left} left, costs ★★)" if left > 0 else "read the README again, or `learn giveup`"
        print(
            ui.paint(f"\n ✗ Not yet (attempt {attempts}).", "red", bold=True),
            ui.dim(f"Fix it and re-run. Stuck? {tip}"),
        )
        return 1
    length = scoring.solution_length(ws / exercise.open) if exercise.par is not None else None
    stars = scoring.stars_for(
        hints_used=before["hints_used"], gave_up=before["gave_up"], attempts=attempts, par=exercise.par, length=length
    )
    after = {
        **before,
        "attempts": attempts,
        "passed": True,
        "stars": max(before["stars"], stars),
        "xp": max(before["xp"], exercise.xp * stars),
    }
    old_xp = progress.total_xp(data)
    updated = progress.with_entry(data, exercise.key, after)
    progress.save(updated)
    _celebrate(exercise, before, after, old_xp, progress.total_xp(updated), length)
    track = tracks_mod.find_track(all_tracks, exercise.track)
    upcoming = next_in_track(track, updated) if track else None
    if upcoming:
        print(ui.dim(f" next: {upcoming.key} — `learn next` or <leader>ln"))
    return 0


def cmd_hint(all_tracks: tuple[Track, ...], data: dict, key: str | None) -> int:
    exercise = _current_exercise(all_tracks, key)
    if not exercise.hints:
        ui.info("No hints for this one. Re-read the README, use K (hover) and grd in nvim, or `learn giveup`.")
        return 0
    entry = progress.entry(data, exercise.key)
    index = min(entry["hints_used"], len(exercise.hints) - 1)
    if entry["hints_used"] == 0 and not entry["passed"]:
        ui.warn("Using a hint caps this exercise at ★ (you can still replay later for more).")
    updated = {**entry, "hints_used": max(entry["hints_used"], index + 1)}
    progress.save(progress.with_entry(data, exercise.key, updated))
    print(ui.paint(f"Hint {index + 1}/{len(exercise.hints)}", "yellow", bold=True))
    print(exercise.hints[index])
    return 0


def _solution_files(exercise: Exercise) -> list[tuple[str, Path]]:
    if exercise.kind == "exercism":
        return exercism.reference_files(exercise)
    sol = exercise.source_dir / "solution"
    return [(str(p.relative_to(sol)), p) for p in sorted(sol.rglob("*")) if p.is_file()] if sol.is_dir() else []


def cmd_solution(all_tracks: tuple[Track, ...], data: dict, key: str | None, paths_only: bool) -> int:
    exercise = _current_exercise(all_tracks, key)
    entry = progress.entry(data, exercise.key)
    if not (entry["passed"] or entry["gave_up"]):
        ui.warn("Solutions unlock after you pass (or `learn giveup`, which caps it at ★).")
        return 3
    files = _solution_files(exercise)
    if not files:
        ui.info("No reference solution ships with this exercise.")
        return 0
    for name, path in files:
        if paths_only:
            print(path)
        else:
            print(ui.paint(f"── {name} ", "purple", bold=True) + ui.rule(60 - len(name)))
            print(path.read_text())
    return 0


def cmd_giveup(all_tracks: tuple[Track, ...], data: dict, key: str | None) -> int:
    exercise = _current_exercise(all_tracks, key)
    entry = progress.entry(data, exercise.key)
    progress.save(progress.with_entry(data, exercise.key, {**entry, "gave_up": True}))
    ui.info("No shame. Study it, then close it and rewrite it from memory. Passing still earns ★.")
    return cmd_solution(all_tracks, progress.load(), exercise.key, paths_only=False)


def cmd_reset(all_tracks: tuple[Track, ...], data: dict, key: str, assume_yes: bool) -> int:
    exercise = tracks_mod.resolve(all_tracks, key)
    if exercise is None:
        ui.error(f"unknown exercise {key!r}")
        return 2
    if not assume_yes:
        if not sys.stdin.isatty():
            ui.error("refusing to reset without --yes (non-interactive)")
            return 2
        if input(f"Delete workspace and progress for {key}? [y/N] ").strip().lower() != "y":
            return 1
    removed = workspace.remove(exercise)
    progress.save(progress.without(data, exercise.key))
    ui.info(f"reset {key}" + (" (workspace deleted)" if removed else ""))
    return 0


def cmd_status_json(all_tracks: tuple[Track, ...], data: dict) -> int:
    xp = progress.total_xp(data)
    level = scoring.level_for(xp)
    payload = {
        "xp": xp,
        "level": level,
        "title": scoring.title_for(level),
        "streak": progress.streak(data),
        "current": workspace.read_marker(Path.cwd()),
        "last": data.get("last"),
        "tracks": [
            {
                "slug": t.slug,
                "name": t.name,
                "language": t.language,
                "total": len(t.exercises),
                "passed": _passed_count(t, data),
                "exercises": [
                    {
                        "key": ex.key,
                        "title": ex.title,
                        "difficulty": ex.difficulty,
                        "stars": progress.entry(data, ex.key)["stars"],
                        "passed": progress.entry(data, ex.key)["passed"],
                        "locked": not is_unlocked(t, i, data),
                    }
                    for i, ex in enumerate(t.exercises)
                ],
            }
            for t in all_tracks
        ],
    }
    print(json.dumps(payload))
    return 0


def cmd_docs(lang: str | None, as_json: bool) -> int:
    if lang is None:
        print(ui.paint(" offline docs", "green", bold=True) + ui.dim(f"  ({docs_mod.DOCS_DIR})"))
        for name, entries in docs_mod.registry().items():
            for entry in entries:
                mark = ui.paint("✓", "green") if entry.exists else ui.paint("✗", "red")
                print(f"  {mark} {ui.paint(name, 'cyan'):<18} {entry.title}")
        print(ui.dim("  open one: learn docs <lang>   ·   in nvim: <leader>lD   ·   missing? learn/fetch.sh"))
        return 0
    entries = docs_mod.entries_for(lang)
    if entries is None:
        ui.error(f"no docs for {lang!r}. Try: {', '.join(docs_mod.registry())}")
        return 2
    if as_json:
        print(
            json.dumps([{"title": e.title, "path": str(e.path), "kind": e.kind, "exists": e.exists} for e in entries])
        )
        return 0
    available = [e for e in entries if e.exists]
    if not available:
        ui.error(f"{lang} docs not downloaded yet: run ~/dotfiles/learn/fetch.sh (needs internet once)")
        return 1
    for entry in available:
        print(f"  {ui.paint(entry.title, 'cyan')}: {entry.path}")
    first = available[0]
    if first.kind == "html":
        if not docs_mod.open_in_browser(first.path):
            ui.info(f"no GUI here: open {first.path} in a browser")
        return 0
    nvim = shutil.which("nvim")
    if nvim and sys.stdout.isatty():
        os.execv(nvim, [nvim, str(first.path)])  # a directory opens in oil; Markdown renders inline
    ui.info(f"read it with: nvim {first.path}")
    return 0


def cmd_complete(all_tracks, what: str) -> int:
    if what == "tracks":
        lines = [f"{t.slug}:{t.name}" for t in all_tracks]
    elif what == "exercises":
        lines = [f"{t.slug}/{ex.slug}:{ex.title}" for t in all_tracks for ex in t.exercises]
    else:
        lines = ["c", "cpp", "python", "haskell", "swift", "sv", "shell"]
    print("\n".join(lines))  # "value:description", as zsh _describe expects
    return 0


# ── argument parsing ─────────────────────────────────────────────────────────


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="learn",
        description="Gamified offline trainer. Run with no arguments for the dashboard; "
        "`learn <track>` opens that track's next exercise.",
    )
    sub = parser.add_subparsers(dest="cmd")
    sub.add_parser("tracks", help="list tracks")
    p = sub.add_parser("list", help="exercises in a track")
    p.add_argument("track")
    p.add_argument("--all", action="store_true", help="include locked exercises")
    p = sub.add_parser("start", help="open an exercise (track/slug)")
    p.add_argument("key")
    p.add_argument(
        "--print", dest="as_json", action="store_true", help="prepare and print JSON instead of opening nvim"
    )
    p.add_argument("--force", action="store_true", help="open even if locked")
    p = sub.add_parser("next", help="open the next exercise")
    p.add_argument("track", nargs="?")
    p.add_argument("--print", dest="as_json", action="store_true")
    p = sub.add_parser("prev", aliases=["previous"], help="open the previous exercise")
    p.add_argument("track", nargs="?")
    p.add_argument("--print", dest="as_json", action="store_true")
    for name, text in (
        ("check", "run the tests/check"),
        ("hint", "reveal the next hint"),
        ("giveup", "show the solution (caps at ★)"),
    ):
        p = sub.add_parser(name, help=text)
        p.add_argument("key", nargs="?")
    p = sub.add_parser("solution", help="reference solution (after passing)")
    p.add_argument("key", nargs="?")
    p.add_argument("--paths", action="store_true", help="print file paths only")
    p = sub.add_parser("reset", help="delete workspace + progress for an exercise")
    p.add_argument("key")
    p.add_argument("--yes", action="store_true")
    sub.add_parser("status", help="machine-readable status (JSON)")
    p = sub.add_parser("_complete")  # for shell completion: plain lines, no colour
    p.add_argument("what", choices=("tracks", "exercises", "docs"))
    p = sub.add_parser("docs", help="offline reference docs: c, cpp, python, haskell, swift, sv, shell")
    p.add_argument("lang", nargs="?")
    p.add_argument("--json", dest="as_json", action="store_true", help="list entries as JSON (used by nvim)")
    return parser


def main(argv: list[str] | None = None) -> int:
    argv = sys.argv[1:] if argv is None else list(argv)
    all_tracks = tracks_mod.load_all()
    if argv and argv[0] in {t.slug for t in all_tracks}:
        argv = ["next", *argv]  # `learn <track>` is shorthand for `learn next <track>`
    args = build_parser().parse_args(argv)
    if args.cmd == "docs":
        return cmd_docs(args.lang, args.as_json)
    data = progress.load()
    if not all_tracks:
        ui.error("no tracks found. Run ~/dotfiles/learn/fetch.sh (Exercism) or check learn/tracks/.")
        return 2
    commands = {
        None: lambda: cmd_dashboard(all_tracks, data),
        "tracks": lambda: cmd_tracks(all_tracks, data),
        "list": lambda: cmd_list(all_tracks, data, args.track, args.all),
        "start": lambda: cmd_start(all_tracks, data, args.key, args.as_json, args.force),
        "next": lambda: cmd_next(all_tracks, data, args.track, args.as_json),
        "prev": lambda: cmd_prev(all_tracks, data, args.track, args.as_json),
        "previous": lambda: cmd_prev(all_tracks, data, args.track, args.as_json),
        "check": lambda: cmd_check(all_tracks, data, args.key),
        "hint": lambda: cmd_hint(all_tracks, data, args.key),
        "solution": lambda: cmd_solution(all_tracks, data, args.key, args.paths),
        "giveup": lambda: cmd_giveup(all_tracks, data, args.key),
        "reset": lambda: cmd_reset(all_tracks, data, args.key, args.yes),
        "status": lambda: cmd_status_json(all_tracks, data),
        "_complete": lambda: cmd_complete(all_tracks, args.what),
    }
    return commands[args.cmd]() if args.cmd in commands else 2
