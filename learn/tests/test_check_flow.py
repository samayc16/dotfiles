"""`learn check`: what the learner is told, and what gets counted, in the cases that bite in real use."""

from __future__ import annotations

import os
import unittest

from tests.support import IsolatedHome


class UntouchedStarterTest(IsolatedHome):
    def test_checking_the_untouched_starter_says_so_and_is_not_an_attempt(self) -> None:
        ws = self.start()
        code, out = self.learn("check", cwd=ws)
        self.assertEqual(code, 1, out)
        self.assertIn("answer.txt is unchanged from the starter", out)
        self.assertIn("save", out)
        self.assertEqual(self.entry("demo/01-ex")["attempts"], 0)

    def test_an_edited_but_wrong_file_counts_as_an_attempt(self) -> None:
        ws = self.start()
        (ws / "answer.txt").write_text("nope\n")
        code, out = self.learn("check", cwd=ws)
        self.assertEqual(code, 1, out)
        self.assertNotIn("unchanged from the starter", out)
        self.assertEqual(self.entry("demo/01-ex")["attempts"], 1)

    def test_first_real_try_after_peeking_at_the_starter_still_earns_three_stars(self) -> None:
        ws = self.start()
        self.learn("check", cwd=ws)  # look at what fails before touching anything
        (ws / "answer.txt").write_text("pass\n")
        code, out = self.learn("check", cwd=ws)
        self.assertEqual(code, 0, out)
        entry = self.entry("demo/01-ex")
        self.assertEqual((entry["stars"], entry["xp"], entry["attempts"]), (3, 30, 1))

    def test_check_runs_from_a_subdirectory_of_the_workspace(self) -> None:
        ws = self.start()
        (ws / "answer.txt").write_text("pass\n")
        deeper = ws / "notes" / "deeper"
        deeper.mkdir(parents=True)
        code, out = self.learn("check", cwd=deeper)
        self.assertEqual(code, 0, out)
        self.assertTrue(self.entry("demo/01-ex")["passed"])


class MissingToolchainTest(IsolatedHome):
    def test_a_checker_that_cannot_run_is_not_blamed_on_the_learner(self) -> None:
        ws = self.start()
        (ws / "answer.txt").write_text("toolchain\n")
        code, out = self.learn("check", cwd=ws)
        self.assertEqual(code, 127, out)
        self.assertIn("frobc not found", out)
        self.assertIn("couldn't run", out)
        self.assertNotIn("Not yet", out)
        self.assertEqual(self.entry("demo/01-ex")["attempts"], 0)


class CheckerEnvironmentTest(IsolatedHome):
    def test_checkers_are_told_not_to_colour_when_learn_itself_does_not(self) -> None:
        ws = self.start()
        env_dump = ws / "env.txt"
        check = self.tracks_dir / "demo" / "01-ex" / "check.sh"
        check.write_text(f'env > "{env_dump}"\nexit 1\n')
        os.environ.pop("NO_COLOR", None)
        self.learn("check", cwd=ws)  # stdout is a file here, not a terminal
        self.assertIn("NO_COLOR=1", env_dump.read_text().splitlines())


class PassMessagesTest(IsolatedHome):
    def test_a_hinted_pass_explains_how_to_replay_for_more_stars(self) -> None:
        ws = self.start()
        self.learn("hint", cwd=ws)
        (ws / "answer.txt").write_text("pass\n")
        code, out = self.learn("check", cwd=ws)
        self.assertEqual(code, 0, out)
        self.assertEqual(self.entry("demo/01-ex")["stars"], 1)
        self.assertIn("learn reset demo/01-ex", out)

    def test_hint_warns_once_that_it_caps_the_exercise(self) -> None:
        ws = self.start()
        _, first = self.learn("hint", cwd=ws)
        _, second = self.learn("hint", cwd=ws)
        self.assertIn("caps this exercise at ★", first)
        self.assertNotIn("caps this exercise", second)
        self.assertIn("hint 2 for 01-ex", second)
        self.assertEqual(self.entry("demo/01-ex")["hints_used"], 2)


if __name__ == "__main__":
    unittest.main()
