"""zsh/update-check.zsh and its gate in zshrc, driven through a pseudo-terminal.

The dotfiles CLI is a stub that logs how it was called; state lives in a temporary HOME.
"""

import os
import pty
import select
import shutil
import subprocess
import tempfile
import time
import unittest
from pathlib import Path
from typing import Dict, Optional

ROOT = Path(__file__).resolve().parents[2]
ZSH = shutil.which("zsh")
PROMPT = b"Update now? [y/N]"
STUB = '#!/bin/sh\necho "$*" >>"$HOME/cli.log"\n'


# Some distros' /etc/zsh/zshrc runs compinit first, which can ask about insecure directories.
COMPINIT_PROMPT = b"abort compinit [n]? "


def run_in_pty(argv: list, env: Dict[str, str], answer: Optional[bytes] = None, timeout: float = 10.0) -> bytes:
    """Run argv in $HOME on a terminal; type `answer` once the update prompt shows. Returns all output."""
    leader, follower = pty.openpty()
    proc = subprocess.Popen(argv, stdin=follower, stdout=follower, stderr=follower, env=env, cwd=env["HOME"], close_fds=True)
    os.close(follower)
    out, answered, deadline, compinit_answered = b"", False, time.monotonic() + timeout, 0
    try:
        while time.monotonic() < deadline:
            ready, _, _ = select.select([leader], [], [], 0.1)
            if ready:
                try:
                    chunk = os.read(leader, 4096)
                except OSError:  # the terminal closed: the shell is done
                    break
                if not chunk:
                    break
                out += chunk
                if out.count(COMPINIT_PROMPT) > compinit_answered:
                    os.write(leader, b"y")
                    compinit_answered += 1
                if answer is not None and not answered and PROMPT in out:
                    os.write(leader, answer)
                    answered = True
            elif proc.poll() is not None:
                break
    finally:
        os.close(leader)
        if proc.poll() is None:
            proc.kill()
        proc.wait()
    return out


@unittest.skipUnless(ZSH, "zsh not installed")
class UpdateCheck(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.home = self.tmp / "home"
        self.state = self.home / ".local" / "state" / "dotfiles"
        self.state.mkdir(parents=True)
        self.dotfiles = self.tmp / "dotfiles"
        (self.dotfiles / "bin").mkdir(parents=True)
        (self.dotfiles / "bin" / "dotfiles").write_text(STUB)
        (self.dotfiles / "bin" / "dotfiles").chmod(0o755)
        (self.dotfiles / "VERSION").write_text("2026.11.24\n")
        (self.state / "checked").write_text("")
        (self.state / "latest").write_text("2026.11.30\n")

    def env(self, **extra: str) -> Dict[str, str]:
        env = {k: v for k, v in os.environ.items() if not k.startswith(("XDG_", "DOTFILES", "CI", "GITHUB_"))}
        env.update(HOME=str(self.home), DOTFILES=str(self.dotfiles), TERM="dumb")
        env.update(extra)
        return env

    def check(self, answer: Optional[bytes] = None) -> bytes:
        script = 'source %s; print CHECK-DONE' % (ROOT / "zsh" / "update-check.zsh")
        return run_in_pty([ZSH, "-f", "-c", script], self.env(), answer)

    def cli_calls(self) -> list:
        log = self.home / "cli.log"
        return log.read_text().splitlines() if log.exists() else []

    def test_asks_once_and_remembers_no(self) -> None:
        out = self.check(answer=b"n")
        self.assertIn(b"dotfiles 2026.11.30 is available (you have 2026.11.24). Update now? [y/N]", out)
        self.assertIn(b"CHECK-DONE", out)
        self.assertEqual(self.cli_calls(), [])
        out = self.check()
        self.assertNotIn(PROMPT, out)
        self.assertIn(b"CHECK-DONE", out)

    def test_yes_runs_dotfiles_update(self) -> None:
        self.assertIn(b"CHECK-DONE", self.check(answer=b"y"))
        self.assertEqual(self.cli_calls(), ["update"])

    def test_asks_again_for_the_next_version(self) -> None:
        self.check(answer=b"n")
        (self.state / "latest").write_text("2026.12.01\n")
        self.assertIn(b"dotfiles 2026.12.01 is available", self.check(answer=b"n"))

    def test_quiet_when_up_to_date_or_rolled_forward(self) -> None:
        for latest in ("2026.11.24", "2026.11.3"):
            (self.state / "latest").write_text(latest + "\n")
            self.assertNotIn(PROMPT, self.check())

    def test_quiet_with_no_cache_or_junk_in_it(self) -> None:
        (self.state / "latest").unlink()
        self.assertNotIn(PROMPT, self.check())
        (self.state / "latest").write_text("$(touch /tmp/x)\n")
        self.assertNotIn(PROMPT, self.check())

    def test_git_clone_compares_its_newest_tag(self) -> None:
        (self.dotfiles / "VERSION").unlink()
        git_env = dict(self.env(), GIT_CONFIG_GLOBAL=os.devnull, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@e", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@e")
        for args in (["init", "-q"], ["commit", "-q", "--allow-empty", "-m", "x"], ["tag", "v2026.11.30"]):
            subprocess.run(["git", *args], cwd=self.dotfiles, env=git_env, check=True)
        self.assertNotIn(PROMPT, self.check())

    def test_stale_cache_refreshes_in_the_background(self) -> None:
        (self.state / "checked").unlink()
        self.check(answer=b"n")
        deadline = time.monotonic() + 5
        while "check --quiet" not in self.cli_calls() and time.monotonic() < deadline:
            time.sleep(0.05)
        self.assertIn("check --quiet", self.cli_calls())

    def test_fresh_cache_makes_no_lookup(self) -> None:
        self.check(answer=b"n")
        time.sleep(0.3)
        self.assertNotIn("check --quiet", self.cli_calls())


@unittest.skipUnless(ZSH, "zsh not installed")
class ZshrcGate(unittest.TestCase):
    """The real zshrc only sources the check on a terminal, outside CI, unless opted out."""

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.home = self.tmp / "home"
        state = self.home / ".local" / "state" / "dotfiles"
        state.mkdir(parents=True)
        (state / "checked").write_text("")
        (state / "latest").write_text("2999.1.1\n")
        (self.home / ".zshrc").symlink_to(ROOT / "zshrc")

    def shell(self, tty: bool, **extra: str) -> bytes:
        env = {k: v for k, v in os.environ.items() if not k.startswith(("XDG_", "DOTFILES", "CI", "GITHUB_"))}
        env.update(HOME=str(self.home), ZDOTDIR=str(self.home), TERM="dumb", **extra)
        argv = [ZSH, "-i", "-c", "print SHELL-DONE"]
        if tty:
            return run_in_pty(argv, env, answer=b"n")
        return subprocess.run(argv, env=env, cwd=self.home, stdin=subprocess.DEVNULL, capture_output=True, timeout=30).stdout

    def test_terminal_shell_asks(self) -> None:
        self.assertIn(PROMPT, self.shell(tty=True))

    def test_opt_out_ci_and_no_terminal_never_ask(self) -> None:
        self.assertNotIn(PROMPT, self.shell(tty=True, DOTFILES_NO_UPDATE_CHECK="1"))
        self.assertNotIn(PROMPT, self.shell(tty=True, CI="true"))
        self.assertNotIn(PROMPT, self.shell(tty=False))


if __name__ == "__main__":
    unittest.main()
