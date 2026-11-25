"""install.d/pins.sh: pin lookups, and pin_sync never moving a clone you've changed.

Runs the real shell functions against throwaway local git repos (file:// URLs, no network),
under /bin/bash too where that's bash 3.2 (macOS).
"""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PINS_SH = ROOT / "install.d" / "pins.sh"
BASHES = [b for b in ("bash", "/bin/bash") if shutil.which(b)]
CLONED, HAVE, MOVED, KEPT = 0, 10, 11, 12
GIT_ENV = {
    "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@example.com",
    "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@example.com",
    "GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_NOSYSTEM": "1",
}


def git(*args: str, cwd: Path) -> str:
    env = dict(os.environ, **GIT_ENV)
    return subprocess.run(["git", *args], cwd=cwd, env=env, check=True, capture_output=True, text=True).stdout.strip()


class PinSync(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.upstream = self.tmp / "upstream"
        self.upstream.mkdir()
        git("init", "-q", "-b", "main", cwd=self.upstream)
        git("config", "uploadpack.allowAnySHA1InWant", "true", cwd=self.upstream)
        self.first = self.commit("one")
        self.second = self.commit("two")
        self.url = "file://" + str(self.upstream)
        self.dest = self.tmp / "plugins" / "p"

    def commit(self, text: str) -> str:
        (self.upstream / "file.txt").write_text(text)
        git("add", "file.txt", cwd=self.upstream)
        git("commit", "-q", "-m", text, cwd=self.upstream)
        return git("rev-parse", "HEAD", cwd=self.upstream)

    def sync(self, rev: str, bash: str = "bash") -> int:
        script = 'source "$1"; pin_sync "$2" "$3" "$4"'
        env = dict(os.environ, **GIT_ENV)
        return subprocess.run([bash, "-c", script, "-", str(PINS_SH), self.url, str(self.dest), rev], env=env, capture_output=True).returncode

    def head(self) -> str:
        return git("rev-parse", "HEAD", cwd=self.dest)

    def test_clone_then_have_then_move(self) -> None:
        for bash in BASHES:
            with self.subTest(bash=bash):
                shutil.rmtree(self.dest, ignore_errors=True)
                self.assertEqual(self.sync(self.first, bash), CLONED)
                self.assertEqual(self.head(), self.first)
                self.assertEqual(self.sync(self.first, bash), HAVE)
                self.assertEqual(self.sync(self.second, bash), MOVED)
                self.assertEqual(self.head(), self.second)

    def test_edited_clone_is_kept(self) -> None:
        self.sync(self.first)
        (self.dest / "file.txt").write_text("mine")
        self.assertEqual(self.sync(self.second), KEPT)
        self.assertEqual(((self.dest / "file.txt").read_text(), self.head()), ("mine", self.first))

    def test_clone_with_your_commit_is_kept(self) -> None:
        self.sync(self.first)
        (self.dest / "file.txt").write_text("mine")
        git("commit", "-q", "-am", "mine", cwd=self.dest)
        mine = self.head()
        self.assertEqual(self.sync(self.second), KEPT)
        self.assertEqual(self.head(), mine)

    def test_untracked_files_dont_count_as_changes(self) -> None:
        self.sync(self.first)
        (self.dest / "notes.txt").write_text("scratch")
        self.assertEqual(self.sync(self.second), MOVED)
        self.assertTrue((self.dest / "notes.txt").exists())

    def test_full_clone_from_upstream_moves(self) -> None:
        git("clone", "-q", self.url, str(self.dest), cwd=self.tmp)  # how TPM clones
        self.commit("three")
        third = git("rev-parse", "HEAD", cwd=self.upstream)
        self.assertEqual(self.sync(third), MOVED)
        self.assertEqual(self.head(), third)

    def test_missing_commit_fails(self) -> None:
        self.assertNotIn(self.sync("f" * 40), (CLONED, HAVE, MOVED, KEPT))


class Lookup(unittest.TestCase):
    def run_sh(self, snippet: str, pins: str) -> subprocess.CompletedProcess:
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as handle:
            handle.write(pins)
        self.addCleanup(os.unlink, handle.name)
        env = dict(os.environ, PINS_FILE=handle.name)
        return subprocess.run(["bash", "-c", 'source "$1"; ' + snippet, "-", str(PINS_SH)], env=env, capture_output=True, text=True)

    def test_lookup_and_prefix(self) -> None:
        pins = "# c\n\ntmux/a commit https://x/a 111\n  learn/b  commit  https://x/b  222\ntmux/c commit https://x/c 333\n"
        self.assertEqual(self.run_sh("pin_lookup learn/b", pins).stdout, "https://x/b 222\n")
        self.assertEqual(self.run_sh("pin_lookup nope", pins).returncode, 1)
        self.assertEqual(self.run_sh("pins_with_prefix tmux/", pins).stdout.splitlines(), ["tmux/a https://x/a 111", "tmux/c https://x/c 333"])

    def test_every_learn_pin_fetch_uses_exists(self) -> None:
        fetch = (ROOT / "learn" / "fetch.sh").read_text()
        pinned = {line.split()[0] for line in (ROOT / "pins.txt").read_text().splitlines() if line.startswith("learn/")}
        used = {"learn/exercism-" + t for t in ("python", "c", "cpp", "swift", "rust")}
        used |= {word for line in fetch.splitlines() if line.strip().startswith("sync_repo learn/") for word in line.split()[1:2]}
        self.assertEqual(used, pinned)


if __name__ == "__main__":
    unittest.main()
