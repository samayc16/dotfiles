"""`learn next` / `learn prev` (<leader>ln / <leader>lp) and the `--print` contract nvim relies on."""

from __future__ import annotations

import json
import unittest

from tests.support import IsolatedHome, last_json


class NextTest(IsolatedHome):
    def next_key(self, *args: str, cwd=None) -> str:
        code, out = self.learn("next", *args, "--print", cwd=cwd)
        self.assertEqual(code, 0, out)
        return last_json(out)["key"]

    def test_outside_a_workspace_next_resumes_at_the_first_unpassed_exercise(self) -> None:
        self.assertEqual(self.next_key("demo"), "demo/01-ex")

    def test_inside_an_unpassed_exercise_next_moves_on_instead_of_reopening_it(self) -> None:
        ws = self.start("01-ex")
        self.assertEqual(self.next_key(cwd=ws), "demo/02-ex")
        self.assertEqual(self.next_key("demo", cwd=ws), "demo/02-ex")  # what nvim sends

    def test_next_skips_passed_exercises_and_wraps_back_to_a_skipped_one(self) -> None:
        self.solve("02-ex")
        ws = self.start("03-ex")  # 01 skipped, 02 passed; 04 is open, 05 still locked
        self.assertEqual(self.next_key(cwd=ws), "demo/04-ex")
        ws = self.start("04-ex")
        self.assertEqual(self.next_key(cwd=ws), "demo/01-ex")

    def test_the_pass_banner_suggests_what_next_will_open(self) -> None:
        self.solve("02-ex")
        ws = self.start("03-ex")
        (ws / "answer.txt").write_text("pass\n")
        _, out = self.learn("check", cwd=ws)
        self.assertIn("next: demo/04-ex", out)
        self.assertEqual(self.next_key(cwd=ws), "demo/04-ex")

    def test_next_from_the_last_open_exercise_says_it_is_the_last(self) -> None:
        for i in range(1, 5):
            self.solve(f"{i:02d}-ex")
        code, out = self.learn("next", "--print", cwd=self.start("05-ex"))
        self.assertNotEqual(code, 0)
        self.assertIn("last one left", out)

    def test_when_everything_is_passed_print_mode_says_so_without_fake_json(self) -> None:
        for i in range(1, 6):
            self.solve(f"{i:02d}-ex")
        code, out = self.learn("next", "demo", "--print", cwd=self.ws("05-ex"))
        self.assertNotEqual(code, 0)
        self.assertIn("passed", out)
        self.assertFalse(any(line.startswith("{") for line in out.splitlines()), out)


class PrevTest(IsolatedHome):
    def test_prev_opens_the_exercise_before_the_current_one(self) -> None:
        ws = self.start("03-ex")
        code, out = self.learn("prev", "--print", cwd=ws)
        self.assertEqual(code, 0, out)
        self.assertEqual(last_json(out)["key"], "demo/02-ex")

    def test_prev_at_the_first_exercise_fails_cleanly_in_print_mode(self) -> None:
        ws = self.start("01-ex")
        code, out = self.learn("prev", "demo", "--print", cwd=ws)
        self.assertNotEqual(code, 0)
        self.assertIn("first exercise", out)
        for line in out.splitlines():
            with self.assertRaises(ValueError, msg="nvim would try to decode this as the payload"):
                json.loads(line)


if __name__ == "__main__":
    unittest.main()
