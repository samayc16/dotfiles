"""Persistent progress (~/learn/progress.json).

Every update returns a NEW dict; `save` writes atomically (temp file + rename) so a
crash mid-write never corrupts history. A missing or corrupt file starts fresh
(the corrupt one is kept as progress.json.corrupt for inspection).
"""

from __future__ import annotations

import contextlib
import copy
import datetime as dt
import json
import os
import tempfile
from pathlib import Path

from . import ui

LEARN_HOME = Path(os.environ.get("LEARN_HOME", Path.home() / "learn"))
PROGRESS_FILE = LEARN_HOME / "progress.json"
VERSION = 1


def empty() -> dict:
    return {"version": VERSION, "exercises": {}, "days": [], "last": None}


def load(path: Path = PROGRESS_FILE) -> dict:
    if not path.exists():
        return empty()
    try:
        data = json.loads(path.read_text())
        if not isinstance(data, dict) or not isinstance(data.get("exercises"), dict):
            raise ValueError("unexpected shape")
        return {**empty(), **data}
    except (OSError, ValueError) as exc:
        backup = path.with_suffix(".json.corrupt")
        with contextlib.suppress(OSError):
            path.replace(backup)
        ui.warn(f"progress file was unreadable ({exc}); starting fresh. Old copy: {backup}")
        return empty()


def save(data: dict, path: Path = PROGRESS_FILE) -> None:
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
