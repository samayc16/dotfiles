"""Exercism test commands: what a learner sees on every `learn check` should be their tests, not noise."""

from __future__ import annotations

import unittest
from pathlib import Path

from tests import support  # noqa: F401  (isolates LEARN_HOME first)
from learnlib import exercism
from learnlib.model import Exercise


def exercise(track: str) -> Exercise:
    return Exercise(
        track=track, slug="lasagna", title="Lasagna", difficulty=1, xp=15, source_dir=Path("/x"),
        files=("lasagna.cpp",), open="lasagna.cpp", kind="exercism", language=track,
    )


class TestCommandTest(unittest.TestCase):
    def test_cpp_configure_hides_cmakes_deprecation_warning_for_the_exercism_minimum(self) -> None:
        cmd, _ = exercism.test_command(exercise("cpp"), Path("/no/venv/python"))
        self.assertIn("-Wno-deprecated", cmd[-1])
        self.assertIn("-DEXERCISM_RUN_ALL_TESTS=1", cmd[-1])


if __name__ == "__main__":
    unittest.main()
