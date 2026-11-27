"""Persistent progress (~/learn/progress.json).

Every update returns a NEW dict; `save` writes atomically (temp file + rename) so a
crash mid-write never corrupts history. A missing or unreadable file starts fresh; a
readable one with damaged parts (a hand edit, a bad merge) keeps every entry that still
makes sense. Either way the original is kept as progress.json.corrupt for inspection.
"""

from __future__ import annotations

import contextlib
import copy
import datetime as dt
import json
import os
import shutil
import tempfile
from pathlib import Path
from typing import Optional

from . import ui

LEARN_HOME = Path(os.environ.get("LEARN_HOME", Path.home() / "learn"))
PROGRESS_FILE = LEARN_HOME / "progress.json"
VERSION = 1


def empty() -> dict:
    return {"version": VERSION, "exercises": {}, "days": [], "last": None}


ENTRY_FIELDS = {"attempts": int, "hints_used": int, "gave_up": bool, "passed": bool, "stars": int, "xp": int}


def _clean_entry(raw: object) -> Optional[dict]:
    """One exercise entry without its wrongly typed known fields (None if it isn't an entry at all).
    Fields this version doesn't know are kept, so a newer learn's data survives an older one."""
    if not isinstance(raw, dict):
        return None
    clean = {name: value for name, value in raw.items() if name not in ENTRY_FIELDS}
    for name, kind in ENTRY_FIELDS.items():
        value = raw.get(name)
        if kind is bool and isinstance(value, bool):
            clean[name] = value
        elif kind is int and isinstance(value, (int, float)) and not isinstance(value, bool):
            clean[name] = max(0, min(3, int(value))) if name == "stars" else max(0, int(value))
    return clean


def _is_day(value: object) -> bool:
    try:
        dt.date.fromisoformat(value)  # type: ignore[arg-type]
        return True
    except (TypeError, ValueError):
        return False


def _repaired(data: dict) -> dict:
    cleaned = {key: _clean_entry(value) for key, value in data["exercises"].items()}
    days = data.get("days") if isinstance(data.get("days"), list) else []
    last = data.get("last")
    return {
        **data,
        "exercises": {key: entry for key, entry in cleaned.items() if entry is not None},
        "days": sorted({day for day in days if _is_day(day)}),
        "last": last if isinstance(last, str) else None,
    }


def load(path: Optional[Path] = None) -> dict:
    path = path or PROGRESS_FILE  # looked up per call: a default argument would freeze it at import
    if not path.exists():
        return empty()
    backup = path.with_suffix(".json.corrupt")
    try:
        data = json.loads(path.read_text())
        if not isinstance(data, dict) or not isinstance(data.get("exercises"), dict):
            raise ValueError("unexpected shape")
    except (OSError, ValueError) as exc:
        with contextlib.suppress(OSError):
            path.replace(backup)
        ui.warn(f"progress file was unreadable ({exc}); starting fresh. Old copy: {backup}")
        return empty()
    as_read = {**empty(), **data}
    repaired = _repaired(as_read)
    if repaired != as_read:
        with contextlib.suppress(OSError):
            shutil.copyfile(str(path), str(backup))
            save(repaired, path)
        ui.warn(f"progress file had damaged entries; kept everything readable. Original: {backup}")
    return repaired


def save(data: dict, path: Optional[Path] = None) -> None:
    path = path or PROGRESS_FILE
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".progress-", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as fh:
            json.dump(data, fh, indent=2, sort_keys=True)
        os.replace(tmp, path)
    except BaseException:
        Path(tmp).unlink(missing_ok=True)
        raise


def entry(data: dict, key: str) -> dict:
    defaults = {"attempts": 0, "hints_used": 0, "gave_up": False, "passed": False, "stars": 0, "xp": 0}
    return {**defaults, **data["exercises"].get(key, {})}


def with_entry(data: dict, key: str, updated: dict) -> dict:
    new = copy.deepcopy(data)
    new["exercises"][key] = updated
    new["last"] = key
    return new


def touch_today(data: dict, today: dt.date | None = None) -> dict:
    day = (today or dt.date.today()).isoformat()
    if day in data["days"]:
        return data
    new = copy.deepcopy(data)
    new["days"] = sorted({*data["days"], day})[-400:]
    return new


def without(data: dict, key: str) -> dict:
    new = copy.deepcopy(data)
    new["exercises"].pop(key, None)
    return new


def streak(data: dict, today: dt.date | None = None) -> int:
    days = {dt.date.fromisoformat(d) for d in data.get("days", [])}
    current = today or dt.date.today()
    if current not in days:
        current -= dt.timedelta(days=1)  # a streak survives until you miss a whole day
    count = 0
    while current in days:
        count += 1
        current -= dt.timedelta(days=1)
    return count


def total_xp(data: dict) -> int:
    return sum(int(e.get("xp", 0)) for e in data["exercises"].values())
