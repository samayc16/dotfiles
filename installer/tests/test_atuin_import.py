"""install.d/zsh.sh imports the zsh history into atuin once, and never fails the step over it.

Sources the real step (its main doesn't run when sourced) with a fake `atuin` that logs its calls.
"""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path
from typing import List

ROOT = Path(__file__).resolve().parents[2]
FAKE_ATUIN = '#!/bin/sh\necho "atuin $* SHELL=${SHELL##*/} HISTFILE=$HISTFILE" >>"$HOME/calls.log"\nexit ${ATUIN_EXIT:-0}\n'


@unittest.skipUnless(shutil.which("zsh"), "zsh not installed")
class AtuinImport(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.home = self.tmp / "home"
        self.home.mkdir()
        self.bin = self.tmp / "bin"
        self.bin.mkdir()
        (self.bin / "atuin").write_text(FAKE_ATUIN)
        (self.bin / "atuin").chmod(0o755)
        self.marker = self.home / ".local" / "state" / "dotfiles" / "atuin-imported"
        self.env = {k: v for k, v in os.environ.items() if not k.startswith(("XDG_", "DOTFILES"))}
        self.env.update(HOME=str(self.home), PATH="%s:/usr/bin:/bin" % self.bin, NO_COLOR="1", DRY_RUN="0")

    def import_history(self, **extra: str) -> str:
        script = 'source "$1"; import_history'
        done = subprocess.run(["bash", "-c", script, "-", str(ROOT / "install.d" / "zsh.sh")], env=dict(self.env, **extra), capture_output=True, text=True)
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
        return done.stdout + done.stderr

    def calls(self) -> List[str]:
        log = self.home / "calls.log"
        return log.read_text().splitlines() if log.exists() else []

    def test_imports_the_zsh_history_once(self) -> None:
        (self.home / ".zsh_history").write_text(": 1700000000:0;echo one\n")
        self.assertIn("imported", self.import_history())
        self.assertEqual(self.calls(), ["atuin import auto SHELL=zsh HISTFILE=%s" % (self.home / ".zsh_history")])
        self.assertTrue(self.marker.exists())
        self.assertIn("imported earlier", self.import_history())
        self.assertEqual(len(self.calls()), 1)

    def test_no_history_yet_marks_it_done_without_importing(self) -> None:
        self.assertIn("no zsh history", self.import_history())
        self.assertEqual(self.calls(), [])
        self.assertTrue(self.marker.exists())

    def test_a_failed_import_warns_and_tries_again_next_time(self) -> None:
        (self.home / ".zsh_history").write_text(": 1700000000:0;echo one\n")
        self.assertIn("could not import", self.import_history(ATUIN_EXIT="1"))
        self.assertFalse(self.marker.exists())
        self.import_history()
        self.assertEqual(len(self.calls()), 2)

    def test_dry_run_and_no_atuin_do_nothing(self) -> None:
        (self.home / ".zsh_history").write_text(": 1700000000:0;echo one\n")
        self.assertIn("would import", self.import_history(DRY_RUN="1"))
        (self.bin / "atuin").unlink()
        self.import_history()
        self.assertEqual(self.calls(), [])
        self.assertFalse(self.marker.exists())


if __name__ == "__main__":
    unittest.main()
