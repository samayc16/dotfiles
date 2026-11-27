"""Terminal output: columns and boxes must line up when colour is on (as in nvim's task panel)."""

from __future__ import annotations

import os
import unittest
from unittest import mock

from tests.support import IsolatedHome
from learnlib import ui
from learnlib.scoring import strip_ansi


class WidthTest(unittest.TestCase):
    def test_display_width_ignores_colour_and_counts_wide_glyphs(self) -> None:
        with mock.patch.dict(os.environ, {"LEARN_FORCE_COLOR": "1"}):
            os.environ.pop("NO_COLOR", None)
            self.assertEqual(ui.width(ui.paint("★★", "yellow") + ui.dim("☆")), 3)
        self.assertEqual(ui.width("par ⛳"), 6)

    def test_pad_and_truncate_by_what_the_eye_sees(self) -> None:
        with mock.patch.dict(os.environ, {"LEARN_FORCE_COLOR": "1"}):
            os.environ.pop("NO_COLOR", None)
            padded = ui.pad(ui.paint("easy", "green"), 8)
            self.assertEqual(strip_ansi(padded), "easy    ")
        self.assertEqual(ui.pad("abcdef", 4), "abc…")

    def test_banner_box_is_rectangular_with_colour_on(self) -> None:
        with mock.patch.dict(os.environ, {"LEARN_FORCE_COLOR": "1"}):
            os.environ.pop("NO_COLOR", None)
            box = ui.banner(["PASSED  Thing", f"{ui.stars(1)}   +10 XP", "within par ⛳"])
        widths = {ui.width(line) for line in box.splitlines()}
        self.assertEqual(len(widths), 1, strip_ansi(box))


class ColumnsTest(IsolatedHome):
    def test_tracks_and_list_columns_line_up_in_colour(self) -> None:
        os.environ.pop("NO_COLOR", None)
        os.environ["LEARN_FORCE_COLOR"] = "1"
        _, listing = self.learn("list", "demo")
        rows = [strip_ansi(line) for line in listing.splitlines() if "Exercise" in line]
        self.assertEqual(len({row.index("easy") for row in rows}), 1, rows)
        self.assertTrue(all(row[row.index("easy") + 4 : row.index("easy") + 6] == "  " for row in rows), rows)
        _, tracks = self.learn("tracks")
        line = next(strip_ansi(line) for line in tracks.splitlines() if "demo" in line)
        self.assertRegex(line, r"^ demo {20,}\s+0/5")


if __name__ == "__main__":
    unittest.main()
