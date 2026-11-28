"""The CI report job (.github/ci/report.sh) against a fake `gh`: a failed run on main opens an
issue assigned to the owner or comments on the open one; a passing run closes it."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / ".github" / "ci" / "report.sh"

# Logs each call; `issue list` answers with $OPEN_ISSUE (the number of the open issue, if any).
FAKE_GH = """#!/usr/bin/env bash
printf '%s\\n' "$*" >>"$GH_LOG"
case "$1 $2" in
  "issue list") [ -n "${OPEN_ISSUE:-}" ] && echo "$OPEN_ISSUE" ;;
  "run view") echo "- linux (debian:12, root)" ;;
  "issue create" | "issue comment") while [ $# -gt 0 ]; do [ "$1" = --body-file ] && cat "$2" >>"$GH_LOG.body"; shift; done ;;
esac
exit 0
"""


class Report(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        bin_dir = self.tmp / "bin"
        bin_dir.mkdir()
        (bin_dir / "gh").write_text(FAKE_GH)
        (bin_dir / "gh").chmod(0o755)
        self.log = self.tmp / "gh.log"
        self.env = dict(
            os.environ,
            PATH="%s:%s" % (bin_dir, os.environ["PATH"]),
            GH_LOG=str(self.log),
            RUN_ID="42",
            RUN_URL="https://github.com/o/r/actions/runs/42",
            GITHUB_SHA="0" * 40,
            GITHUB_REPOSITORY_OWNER="owner",
        )

    def report(self, results: str, event: str = "schedule", open_issue: str = "", changes: str = "") -> list:
        if changes:
            (self.tmp / "ci-artifacts").mkdir()
            (self.tmp / "ci-artifacts" / "changes.txt").write_text(changes)
        env = dict(self.env, RESULTS=results, EVENT=event, OPEN_ISSUE=open_issue)
        subprocess.run(["bash", str(SCRIPT)], cwd=self.tmp, env=env, check=True, capture_output=True, text=True)
        return [line for line in self.log.read_text().splitlines() if not line.startswith(("issue list", "run view"))] if self.log.exists() else []

    def body(self) -> str:
        return Path(str(self.log) + ".body").read_text()

    def test_a_failed_nightly_run_opens_an_issue_assigned_to_the_owner(self) -> None:
        calls = self.report("success failure skipped", changes="nvim/oil.nvim: aaa → bbb\n")
        self.assertEqual(len(calls), 1)
        self.assertIn("issue create --title Nightly update is failing", calls[0])
        self.assertIn("--assignee owner", calls[0])
        self.assertIn("- linux (debian:12, root)", self.body())
        self.assertIn("nvim/oil.nvim: aaa → bbb", self.body())
        self.assertIn("runs/42", self.body())

    def test_a_second_failure_comments_on_the_open_issue(self) -> None:
        calls = self.report("failure", open_issue="7")
        self.assertEqual(len(calls), 1)
        self.assertTrue(calls[0].startswith("issue comment 7 "))

    def test_a_passing_run_closes_the_open_issue(self) -> None:
        self.assertEqual(self.report("success success skipped", open_issue="7"), ["issue close 7 --comment Passing again: https://github.com/o/r/actions/runs/42"])

    def test_a_passing_run_with_no_issue_does_nothing(self) -> None:
        self.assertEqual(self.report("success skipped"), [])

    def test_a_cancelled_run_is_not_a_failure(self) -> None:
        self.assertEqual(self.report("success cancelled"), [])

    def test_pushes_have_their_own_issue(self) -> None:
        calls = self.report("failure", event="push")
        self.assertIn("issue create --title CI is failing on main", calls[0])


if __name__ == "__main__":
    unittest.main()
