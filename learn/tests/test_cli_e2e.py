"""The real `bin/learn`, run as a subprocess against a temp LEARN_HOME, on the real shell track.

The shell track needs only bash, perl and grep/sed/awk, so this runs anywhere learn does
(including CI). Output is piped, as when an assistant or a script runs `learn check`.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from tests.support import LEARN_BIN, REPO, last_json, run_cli, tool_path

SHELL = REPO / "learn" / "tracks" / "shell"
FIRST = "shell/01-first-grep"
ANSI = re.compile(r"\x1b\[")


class ShellTrackFlowTest(unittest.TestCase):
    def setUp(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.home = Path(tmp.name).resolve()

    def learn(self, *args: str, cwd: Path = None, **env: str) -> subprocess.CompletedProcess:
        proc = run_cli(args, self.home, cwd=cwd, env=env)
        self.assertNotIn("Traceback", proc.stderr, args)
        return proc

    def progress(self) -> dict:
        return json.loads((self.home / "progress.json").read_text())["exercises"]

    def test_a_learner_session_from_start_to_solution(self) -> None:
        started = self.learn("start", FIRST, "--print")
        self.assertEqual(started.returncode, 0, started.stderr)
        payload = last_json(started.stdout)
        ws = Path(payload["workspace"])
        self.assertEqual((payload["open"], payload["files"]), ("solution.sh", ["solution.sh"]))
        self.assertTrue((ws / "README.md").is_file() and (ws / ".learn.json").is_file())

        starter = self.learn("check", cwd=ws)
        self.assertEqual(starter.returncode, 1)
        self.assertIn("Output does not match yet", starter.stdout)
        self.assertLess(starter.stdout.index("checking shell/01-first-grep"), starter.stdout.index("Output does not"))

        self.assertEqual(self.learn("solution", cwd=ws).returncode, 3)
        hint = self.learn("hint", cwd=ws)
        self.assertIn("Hint 1/", hint.stdout)
        self.assertIn("caps this exercise", hint.stderr)

        shutil.copyfile(str(SHELL / "01-first-grep" / "solution" / "solution.sh"), str(ws / "solution.sh"))
        passed = self.learn("check", cwd=ws)
        self.assertEqual(passed.returncode, 0, passed.stdout)
        self.assertIn("PASSED", passed.stdout)
        self.assertEqual(self.progress()[FIRST]["stars"], 1)
        self.assertEqual(self.progress()[FIRST]["xp"], 10)

        solution = self.learn("solution", "--paths", cwd=ws)
        self.assertEqual(solution.stdout.strip(), str(SHELL / "01-first-grep" / "solution" / "solution.sh"))
        status = last_json(self.learn("status", cwd=ws).stdout)
        self.assertEqual((status["xp"], status["current"]), (10, FIRST))
        shell = next(t for t in status["tracks"] if t["slug"] == "shell")
        self.assertEqual(shell["passed"], 1)
        self.assertIn("1/35", self.learn().stdout)

    def test_golfing_under_par_after_a_plain_pass_earns_the_third_star(self) -> None:
        ws = Path(last_json(self.learn("start", FIRST, "--print").stdout)["workspace"])
        long_way = 'cat "$DATA/app.log" | grep ERROR | cat | cat | cat | cat | cat | cat | cat | cat | cat\n'
        (ws / "solution.sh").write_text((ws / "solution.sh").read_text() + long_way)
        first = self.learn("check", cwd=ws)
        self.assertEqual(first.returncode, 0, first.stdout)
        self.assertEqual(self.progress()[FIRST]["stars"], 2)
        self.assertIn("golf it", first.stdout)
        shutil.copyfile(str(SHELL / "01-first-grep" / "solution" / "solution.sh"), str(ws / "solution.sh"))
        self.assertEqual(self.learn("check", cwd=ws).returncode, 0)
        self.assertEqual(self.progress()[FIRST]["stars"], 3)

    def test_piped_output_has_no_colour_and_forced_colour_does(self) -> None:
        self.assertIsNone(ANSI.search(self.learn().stdout))
        self.assertIsNone(ANSI.search(self.learn(NO_COLOR="1", LEARN_FORCE_COLOR="1").stdout))
        self.assertIsNotNone(ANSI.search(self.learn(LEARN_FORCE_COLOR="1").stdout))

    def test_a_closed_pipe_ends_quietly(self) -> None:
        read_end, write_end = os.pipe()
        os.close(read_end)  # the reader is already gone, as with `learn list shell --all | head -1`
        env = {**os.environ, "LEARN_HOME": str(self.home)}
        proc = subprocess.run(
            [sys.executable, str(LEARN_BIN), "list", "shell", "--all"],
            env=env,
            stdout=write_end,
            stderr=subprocess.PIPE,
            timeout=60,
        )
        os.close(write_end)
        self.assertNotIn(b"Traceback", proc.stderr)
        self.assertNotIn(b"BrokenPipeError", proc.stderr)

    def test_restarting_a_passed_exercise_keeps_the_learners_solution(self) -> None:
        ws = Path(last_json(self.learn("start", FIRST, "--print").stdout)["workspace"])
        shutil.copyfile(str(SHELL / "01-first-grep" / "solution" / "solution.sh"), str(ws / "solution.sh"))
        self.learn("check", cwd=ws)
        mine = (ws / "solution.sh").read_text()
        for extra in ((), ("--force",)):
            again = self.learn("start", FIRST, "--print", *extra)
            self.assertEqual(again.returncode, 0, again.stderr)
            self.assertEqual((ws / "solution.sh").read_text(), mine)
        self.assertEqual(self.learn("start", "shell/30-awk-join", "--print").returncode, 3)  # locked
        self.assertEqual(self.learn("start", "shell/30-awk-join", "--print", "--force").returncode, 0)

    def test_outside_a_workspace_commands_explain_what_to_do(self) -> None:
        for command in ("check", "hint", "solution", "giveup"):
            proc = self.learn(command)
            self.assertNotEqual(proc.returncode, 0)
            self.assertIn("Not inside a learn workspace", proc.stdout + proc.stderr)


class MissingToolchainTest(unittest.TestCase):
    """With the language's tools off PATH, every checker says what's missing and nothing is counted."""

    CASES = {
        "haskell-koans/01-expressions": "runghc",
        "c-koans/01-c23-basics": "clang or gcc",
        "cpp-koans/01-modern-basics": "clang++ or g++",
        "swift-koans/01-optionals": "swiftc",
        "python-koans/01-fstrings": "Python 3.12",
        "systemverilog/01-gates": "verilator",
    }

    def test_each_checker_reports_its_missing_tool(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        home = Path(tmp.name).resolve()
        path = tool_path(home, ["bash", "dirname", "mktemp", "rm", "cat"])
        env = {"PATH": path, "CC": "", "CXX": "", "HOME": str(home)}
        for key, tool in self.CASES.items():
            with self.subTest(key=key):
                ws = Path(last_json(run_cli(["start", key, "--print"], home).stdout)["workspace"])
                proc = run_cli(["check"], home, cwd=ws, env=env)
                self.assertEqual(proc.returncode, 127, proc.stdout + proc.stderr)
                self.assertIn(tool, proc.stdout)
                self.assertIn("couldn't run", proc.stdout + proc.stderr)
                saved = home / "progress.json"
                exercises = json.loads(saved.read_text())["exercises"] if saved.exists() else {}
                self.assertEqual(exercises.get(key, {}).get("attempts", 0), 0)


if __name__ == "__main__":
    unittest.main()
