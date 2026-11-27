"""progress.json: a damaged file must never take the CLI (or <leader>ll, which runs `learn status`) down."""

from __future__ import annotations

import json
import unittest
from pathlib import Path
from unittest import mock

from tests.support import IsolatedHome
from learnlib import progress

GOOD = {"attempts": 2, "hints_used": 0, "gave_up": False, "passed": True, "stars": 2, "xp": 20}


class DamagedProgressTest(IsolatedHome):
    def write(self, data: object) -> None:
        (self.home / "progress.json").write_text(data if isinstance(data, str) else json.dumps(data))

    def assert_every_command_survives(self) -> None:
        for args in ((), ("status",), ("tracks",), ("list", "demo"), ("next", "--print")):
            code, out = self.learn(*args)
            self.assertNotIn("Traceback", out, args)
            self.assertEqual(code, 0, f"{args}: {out}")

    def test_a_healthy_file_is_left_alone_and_unknown_fields_survive(self) -> None:
        healthy = {"version": 1, "exercises": {"demo/01-ex": {**GOOD, "from_a_newer_learn": [1]}}, "days": ["2026-01-02"], "last": "demo/01-ex"}
        self.write(healthy)
        before = (self.home / "progress.json").read_text()
        self.assertEqual(progress.load(self.home / "progress.json")["exercises"]["demo/01-ex"]["from_a_newer_learn"], [1])
        self.assertEqual((self.home / "progress.json").read_text(), before)
        self.assertFalse((self.home / "progress.json.corrupt").exists())

    def test_bad_entries_are_dropped_and_good_ones_kept(self) -> None:
        self.write(
            {
                "version": 1,
                "exercises": {"demo/01-ex": GOOD, "demo/02-ex": 3, "demo/03-ex": {"xp": "lots", "stars": [1]}},
                "days": ["2026-01-02", "not-a-date", 7],
                "last": 42,
            }
        )
        self.assert_every_command_survives()
        data = progress.load(self.home / "progress.json")
        self.assertEqual(data["exercises"]["demo/01-ex"], GOOD)
        self.assertNotIn("demo/02-ex", data["exercises"])
        self.assertEqual(progress.entry(data, "demo/03-ex")["xp"], 0)
        self.assertEqual(data["days"], ["2026-01-02"])
        self.assertIsNone(data["last"])

    def test_wrong_types_at_the_top_level_start_fresh_with_a_backup(self) -> None:
        backup = self.home / "progress.json.corrupt"
        for broken in ('{"exercises": {}, "days": 5}', "[]", "", "{not json", '{"exercises": []}'):
            with self.subTest(broken=broken):
                if backup.exists():
                    backup.unlink()
                self.write(broken)
                self.assert_every_command_survives()
                self.assertEqual(backup.read_text(), broken)

    def test_a_repaired_file_keeps_a_copy_of_the_original(self) -> None:
        original = {"exercises": {"demo/01-ex": GOOD, "demo/02-ex": "junk"}, "days": []}
        self.write(original)
        with mock.patch.object(progress.ui, "warn") as warn:
            progress.load(self.home / "progress.json")
        warn.assert_called_once()
        self.assertEqual(progress.load(self.home / "progress.json")["exercises"], {"demo/01-ex": GOOD})  # saved repaired
        self.assertEqual(json.loads((self.home / "progress.json.corrupt").read_text()), original)

    def test_streak_and_xp_tolerate_what_load_repaired(self) -> None:
        self.write({"exercises": {"demo/01-ex": {**GOOD, "xp": 20.0}}, "days": ["2026-01-02"]})
        data = progress.load(self.home / "progress.json")
        self.assertEqual(progress.total_xp(data), 20)
        self.assertGreaterEqual(progress.streak(data), 0)


class WhereProgressLivesTest(IsolatedHome):
    def test_load_and_save_follow_the_configured_file_not_an_import_time_default(self) -> None:
        progress.save(progress.with_entry(progress.empty(), "demo/01-ex", GOOD))
        self.assertTrue((self.home / "progress.json").exists())
        self.assertEqual(progress.load()["exercises"]["demo/01-ex"], GOOD)

    def test_the_suite_never_points_at_the_real_learn_home(self) -> None:
        real = (Path.home() / "learn").resolve()
        for module_home in (progress.LEARN_HOME, progress.PROGRESS_FILE.parent):
            self.assertNotEqual(Path(module_home).resolve(), real)


if __name__ == "__main__":
    unittest.main()
