"""Load tracks written in the shared format (learn/tracks/<track>/track.json)."""

from __future__ import annotations

import json
from pathlib import Path

from . import exercism, ui
from .model import Exercise, Track

REPO_LEARN_DIR = Path(__file__).resolve().parent.parent
TRACKS_DIR = REPO_LEARN_DIR / "tracks"

# Display order: training tracks interleaved so each language's koans precede its Exercism set.
PREFERRED_ORDER = (
    "shell",
    "python-koans",
    "python",
    "c-koans",
    "c",
    "cpp-koans",
    "cpp",
    "swift-koans",
    "swift",
    "systemverilog",
    "haskell-koans",
)


def _read_json(path: Path) -> dict | None:
    try:
        return json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        ui.warn(f"skipping {path}: {exc}")
        return None


def _clamp(value: object, low: int, high: int, default: int) -> int:
    try:
        return max(low, min(high, int(value)))  # type: ignore[arg-type]
    except (TypeError, ValueError):
        return default


def load_exercise(track: str, language: str, ex_dir: Path) -> Exercise | None:
    meta = _read_json(ex_dir / "exercise.json")
    if meta is None:
        return None
    files = tuple(str(f) for f in meta.get("files", []))
    if not files:
        ui.warn(f"skipping {ex_dir}: exercise.json lists no files")
        return None
    par = meta.get("par")
    return Exercise(
        track=track,
        slug=ex_dir.name,
        title=str(meta.get("title", ex_dir.name)),
        difficulty=_clamp(meta.get("difficulty"), 1, 5, 1),
        xp=_clamp(meta.get("xp"), 1, 1000, 10),
        source_dir=ex_dir,
        files=files,
        open=str(meta.get("open", files[0])),
        concepts=tuple(str(c) for c in meta.get("concepts", [])),
        hints=tuple(str(h) for h in meta.get("hints", [])),
        par=int(par) if isinstance(par, (int, float)) and par > 0 else None,
        kind="format",
        language=language,
        extra={"check": str(meta.get("check", "check.sh"))},
    )


def load_format_track(track_dir: Path) -> Track | None:
    meta = _read_json(track_dir / "track.json")
    if meta is None:
        return None
    slug = str(meta.get("slug", track_dir.name))
    language = str(meta.get("language", ""))
    exercises = []
    for name in meta.get("order", []):
        ex_dir = track_dir / name
        if not ex_dir.is_dir():
            ui.warn(f"{slug}: missing exercise dir {name}")
            continue
        exercise = load_exercise(slug, language, ex_dir)
        if exercise:
            exercises.append(exercise)
    return Track(
        slug=slug,
        name=str(meta.get("name", slug)),
        language=language,
        description=str(meta.get("description", "")),
        exercises=tuple(exercises),
        kind="format",
    )


def _sort_key(track: Track) -> tuple[int, str]:
    try:
        return (PREFERRED_ORDER.index(track.slug), track.slug)
    except ValueError:
        return (len(PREFERRED_ORDER), track.slug)


def load_all() -> tuple[Track, ...]:
    found: list[Track] = []
    if TRACKS_DIR.is_dir():
        for track_dir in sorted(TRACKS_DIR.iterdir()):
            if track_dir.name.startswith(("_", ".")) or not (track_dir / "track.json").is_file():
                continue
            track = load_format_track(track_dir)
            if track and track.exercises:
                found.append(track)
    found.extend(exercism.load_all())
    return tuple(sorted(found, key=_sort_key))


def find_track(tracks: tuple[Track, ...], slug: str) -> Track | None:
    return next((t for t in tracks if t.slug == slug), None)


def resolve(tracks: tuple[Track, ...], key: str) -> Exercise | None:
    """`track/slug` -> Exercise."""
    if "/" not in key:
        return None
    track_slug, ex_slug = key.split("/", 1)
    track = find_track(tracks, track_slug)
    return track.find(ex_slug) if track else None
