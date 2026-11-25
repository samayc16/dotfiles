"""scripts/focus.sh, the tmux focus timer, driven with a fake clock (FOCUS_NOW).

tmux, osascript and notify-send are stubs that log how they were called. PATH holds only those
stubs and links to the few real tools the script may use, so no test can reach a real desktop
notifier. Each test runs under every POSIX shell found here (sh, dash, bash).
"""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path
from typing import Dict, List, Optional

ROOT = Path(__file__).resolve().parents[2]
FOCUS = ROOT / "scripts" / "focus.sh"
SHELLS = [s for s in ("sh", "dash", "bash") if shutil.which(s)]
REAL_TOOLS = ("date", "mkdir", "mv", "rm", "sed")
STUB = '#!/bin/sh\nprintf "%%s\\n" "%s $*" >>"$CALLS"\n'
# tmux also answers list-clients, with one attached client
TMUX_STUB = STUB % "tmux" + '[ "$1" = list-clients ] && echo /dev/pts/7\nexit 0\n'
T0 = 1_800_000_000


class Focus(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.bin = self.tmp / "bin"
        self.bin.mkdir()
        for tool in REAL_TOOLS:
            (self.bin / tool).symlink_to(shutil.which(tool))
        self.stub("tmux", TMUX_STUB)
        self.state =self.tmp / "state" / "dotfiles" / "focus"
        self.calls_file = self.tmp / "calls.log"
        self.shell = SHELLS[0]

    def stub(self, name: str, script: Optional[str] = None) -> None:
        path = self.bin / name
        path.write_text(script or STUB % name)
        path.chmod(0o755)

    def run_focus(self, *args: str, now: int = T0, tmux: bool = True, **extra: str) -> subprocess.CompletedProcess:
        env: Dict[str, str] = {
            "PATH": str(self.bin),
            "HOME": str(self.tmp / "home"),
            "XDG_STATE_HOME": str(self.tmp / "state"),
            "FOCUS_NOW": str(now),
            "CALLS": str(self.calls_file),
        }
        if tmux:
            env["TMUX"] = "/tmp/tmux-test/default,1,0"
        env.update(extra)
        return subprocess.run([shutil.which(self.shell), str(FOCUS), *args], env=env, capture_output=True, text=True, timeout=10)

    def status(self, now: int) -> str:
        done = self.run_focus("status", now=now)
        self.assertEqual(done.returncode, 0, done.stderr)
        return done.stdout

    def calls(self) -> List[str]:
        return self.calls_file.read_text().splitlines() if self.calls_file.exists() else []

    def messages(self) -> List[str]:
        return [c for c in self.calls() if c.startswith("tmux display-message")]

    def each_shell(self):
        for shell in SHELLS:
            with self.subTest(shell=shell):
                self.shell = shell
                self.state.unlink(missing_ok=True)
                self.calls_file.unlink(missing_ok=True)
                yield shell

    def state_line(self) -> Optional[str]:
        return self.state.read_text().strip() if self.state.exists() else None

    def test_toggle_starts_fifty_minutes_by_default_and_counts_down(self) -> None:
        for _ in self.each_shell():
            self.assertEqual(self.run_focus("toggle", "").returncode, 0)
            self.assertEqual(self.state_line(), "%d 50" % (T0 + 50 * 60))
            self.assertEqual(self.status(T0), "○ focus 50m  ")
            self.assertEqual(self.status(T0 + 18 * 60), "◔ focus 32m  ")
            self.assertEqual(self.status(T0 + 25 * 60), "◑ focus 25m  ")
            self.assertEqual(self.status(T0 + 40 * 60), "◕ focus 10m  ")
            self.assertEqual(self.status(T0 + 50 * 60 - 1), "◕ focus 1m  ")  # never "0m" while running
            self.assertIn("tmux refresh-client -S", self.calls())

    def test_minutes_from_the_argument_then_the_environment(self) -> None:
        for _ in self.each_shell():
            self.run_focus("start", "25", FOCUS_MINUTES="40")
            self.assertEqual(self.state_line(), "%d 25" % (T0 + 25 * 60))
            self.run_focus("start", FOCUS_MINUTES="40")
            self.assertEqual(self.state_line(), "%d 40" % (T0 + 40 * 60))

    def test_bad_minutes_are_refused(self) -> None:
        for _ in self.each_shell():
            for bad in ("0", "abc", "-5", "1441", "2.5"):
                done = self.run_focus("start", bad)
                self.assertEqual(done.returncode, 2, bad)
                self.assertIn("whole number", done.stderr)
                self.assertIsNone(self.state_line())

    def test_toggle_again_stops_early(self) -> None:
        for _ in self.each_shell():
            self.run_focus("toggle")
            self.run_focus("toggle", now=T0 + 18 * 60 + 30)
            self.assertIsNone(self.state_line())
            self.assertEqual(self.status(T0 + 19 * 60), "")
            self.assertTrue(any("Focus stopped after 18m" in m for m in self.messages()), self.calls())

    def test_the_end_is_announced_once_with_a_desktop_notification(self) -> None:
        self.stub("notify-send")
        for _ in self.each_shell():
            self.run_focus("start", "1")
            self.assertEqual(self.status(T0 + 60), "")
            self.assertIsNone(self.state_line())
            self.assertEqual(self.status(T0 + 70), "")
            done = [c for c in self.messages() if "Focus done" in c]
            self.assertEqual(len(done), 1, self.calls())
            self.assertIn("-d 0", done[0])
            self.assertEqual([c for c in self.calls() if c.startswith("notify-send")], ["notify-send Focus done 1 minutes are up. Take a break."])

    def test_osascript_is_preferred_where_it_exists(self) -> None:
        self.stub("osascript")
        self.stub("notify-send")
        self.run_focus("start", "1")
        self.status(T0 + 61)
        notifiers = [c.split()[0] for c in self.calls() if not c.startswith("tmux")]
        self.assertEqual(notifiers, ["osascript"])

    def test_no_notifier_and_no_tmux_is_silent(self) -> None:
        for _ in self.each_shell():
            self.run_focus("start", "1", tmux=False)
            done = self.run_focus("status", now=T0 + 120, tmux=False)
            self.assertEqual((done.returncode, done.stdout, done.stderr), (0, "", ""))
            self.assertEqual(self.calls(), [])

    def test_toggle_after_an_unannounced_end_starts_a_new_block(self) -> None:
        self.run_focus("start", "5")
        self.run_focus("toggle", now=T0 + 600)
        self.assertEqual(self.state_line(), "%d 50" % (T0 + 600 + 50 * 60))

    def test_idle_status_runs_nothing(self) -> None:
        for _ in self.each_shell():
            self.assertEqual(self.status(T0), "")
            self.assertEqual(self.calls(), [])

    def test_a_corrupt_state_file_is_dropped(self) -> None:
        for _ in self.each_shell():
            self.state.parent.mkdir(parents=True, exist_ok=True)
            self.state.write_text("garbage\n")
            self.assertEqual(self.status(T0), "")
            self.assertIsNone(self.state_line())

    def test_usage(self) -> None:
        done = self.run_focus("bogus")
        self.assertEqual(done.returncode, 2)
        self.assertIn("focus.sh toggle", done.stderr)


if __name__ == "__main__":
    unittest.main()
