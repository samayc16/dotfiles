"""bin/dotfiles: release installs, update, rollback, pruning, and git-clone updates.

Every test runs the real script in a temporary HOME with stub tarballs whose install.sh only
records how it was called; the network is a fake `curl` on PATH. Runs under /bin/bash as well
where that's bash 3.2 (macOS).
"""

import os
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from typing import Dict, List, Optional

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "bin" / "dotfiles"
BASHES = [b for b in ("bash", "/bin/bash") if shutil.which(b)]
GIT_ENV = {
    "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@example.com",
    "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@example.com",
    "GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_NOSYSTEM": "1",
}
STUB_INSTALL = """#!/bin/sh
echo "$(basename "$(cd "$(dirname "$0")" && pwd)") $*" >>"$HOME/installs.log"
exit {code}
"""
# Answers the releases/latest redirect with the tag in $FAKE_LATEST (none: fail like offline).
FAKE_CURL = """#!/bin/sh
for arg in "$@"; do case "$arg" in */releases/latest) [ -n "$FAKE_LATEST" ] || exit 6
  printf 'https://github.com/o/r/releases/tag/v%s' "$FAKE_LATEST"; exit 0 ;; esac; done
exit 6
"""


class Home(unittest.TestCase):
    bash = "bash"

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.home = self.tmp / "home"
        self.home.mkdir()
        self.store = self.home / ".local" / "share" / "dotfiles"
        self.fakebin = self.tmp / "fakebin"
        self.fakebin.mkdir()
        (self.fakebin / "curl").write_text(FAKE_CURL)
        (self.fakebin / "curl").chmod(0o755)

    def env(self, **extra: str) -> Dict[str, str]:
        env = {k: v for k, v in os.environ.items() if not k.startswith(("XDG_", "DOTFILES"))}
        env.update(HOME=str(self.home), PATH="%s:%s" % (self.fakebin, os.environ["PATH"]), NO_COLOR="1", **GIT_ENV)
        env.update(extra)
        return env

    def tarball(self, version: str, code: int = 0, files: Optional[Dict[str, str]] = None) -> Path:
        src = self.tmp / ("src-" + version) / "dotfiles"
        shutil.rmtree(src.parent, ignore_errors=True)
        (src / "bin").mkdir(parents=True)
        (src / "VERSION").write_text(version + "\n")
        (src / "install.sh").write_text(STUB_INSTALL.format(code=code))
        (src / "install.sh").chmod(0o755)
        (src / "zshrc").write_text("# zshrc %s\n" % version)
        shutil.copy(SCRIPT, src / "bin" / "dotfiles")
        for name, text in (files or {}).items():
            (src / name).write_text(text)
        out = self.tmp / ("dotfiles-%s.tar.gz" % version)
        with tarfile.open(out, "w:gz") as tar:
            tar.add(src, arcname="dotfiles")
        return out

    def run_cli(self, *args: str, script: Optional[Path] = None, **env: str) -> subprocess.CompletedProcess:
        """As a user runs it: ~/bin/dotfiles → the current version's, else a downloaded copy."""
        if script is None:
            script = self.store / "current" / "bin" / "dotfiles"
            if not script.exists():
                script = self.tmp / "download" / "bin" / "dotfiles"
                script.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy(SCRIPT, script)
        return subprocess.run([self.bash, str(script), *args], env=self.env(**env), capture_output=True, text=True, cwd=self.tmp)

    def ok(self, *args: str, **env: str) -> str:
        done = self.run_cli(*args, **env)
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
        return done.stdout + done.stderr

    def current(self) -> str:
        return os.readlink(self.store / "current")

    def installs(self) -> List[str]:
        log = self.home / "installs.log"
        return log.read_text().splitlines() if log.exists() else []


class Release(Home):
    def test_install_update_rollback(self) -> None:
        self.ok("install", "--from", str(self.tarball("2026.11.20")), "--profile", "cli")
        self.assertEqual(self.current(), "2026.11.20")
        self.assertTrue((self.store / "2026.11.20" / ".manifest").is_file())
        self.ok("update", "--from", str(self.tarball("2026.11.24")))
        self.assertEqual((self.current(), os.readlink(self.store / "previous")), ("2026.11.24", "2026.11.20"))
        self.assertEqual(self.installs(), ["2026.11.20 --profile cli", "2026.11.24 "])
        self.ok("rollback")
        self.assertEqual((self.current(), os.readlink(self.store / "previous")), ("2026.11.20", "2026.11.24"))
        self.ok("rollback")
        self.assertEqual(self.current(), "2026.11.24")
        self.assertEqual(len(self.installs()), 2)  # a rollback only flips

    def test_failed_install_leaves_current_alone(self) -> None:
        self.ok("install", "--from", str(self.tarball("2026.11.20")))
        done = self.run_cli("update", "--from", str(self.tarball("2026.11.24", code=1)))
        self.assertEqual(done.returncode, 1)
        self.assertIn("still on 2026.11.20", done.stderr)
        self.assertEqual(self.current(), "2026.11.20")
        self.assertTrue((self.store / "2026.11.24").is_dir())  # kept for a retry or a manual switch

    def test_saved_install_flags_are_reused(self) -> None:
        state = self.home / ".local" / "state" / "dotfiles"
        state.mkdir(parents=True)
        (state / "install-args").write_text("--profile\ncli\n--no-sudo\n")
        self.ok("install", "--from", str(self.tarball("2026.11.20")))
        self.ok("update", "--from", str(self.tarball("2026.11.24")), "--profile", "dev")
        self.assertEqual(self.installs(), ["2026.11.20 --profile cli --no-sudo", "2026.11.24 --profile dev"])

    def test_edits_block_an_update_until_forced(self) -> None:
        self.ok("install", "--from", str(self.tarball("2026.11.20")))
        (self.store / "2026.11.20" / "zshrc").write_text("# my edit\n")
        (self.store / "2026.11.20" / "nvim").mkdir()
        (self.store / "2026.11.20" / "nvim" / "lazy-lock.json").write_text("{}")  # rewritten by lazy.nvim: not an edit
        done = self.run_cli("update", "--from", str(self.tarball("2026.11.24")))
        self.assertEqual(done.returncode, 1)
        self.assertIn("zshrc", done.stderr)
        self.assertNotIn("lazy-lock", done.stderr)
        self.assertEqual(self.current(), "2026.11.20")
        self.ok("update", "--force", "--from", str(self.tarball("2026.11.24")))
        self.assertEqual(self.current(), "2026.11.24")
        self.assertEqual((self.store / "2026.11.20" / "zshrc").read_text(), "# my edit\n")

    def test_keeps_three_versions_and_any_you_edited(self) -> None:
        self.ok("install", "--from", str(self.tarball("2026.11.1")))
        (self.store / "2026.11.1" / "zshrc").write_text("# mine\n")
        for day in (2, 3, 4, 10):
            self.ok("update", "--force", "--from", str(self.tarball("2026.11.%d" % day)))
        kept = sorted(p.name for p in self.store.iterdir() if not p.name.startswith(".") and not p.is_symlink())
        self.assertEqual(kept, ["2026.11.1", "2026.11.10", "2026.11.3", "2026.11.4"])
        self.assertEqual(self.ok("list").split(), ["2026.11.1", "(edited)", "2026.11.3", "p", "2026.11.4", "*", "2026.11.10"])

    def test_update_checks_the_newest_release(self) -> None:
        self.ok("install", "--from", str(self.tarball("2026.11.24")))
        self.assertIn("up to date", self.ok("update", FAKE_LATEST="2026.11.24"))
        self.assertIn("up to date", self.ok("update", FAKE_LATEST="2026.11.3"))
        done = self.run_cli("update", FAKE_LATEST="")
        self.assertEqual(done.returncode, 1)
        self.assertIn("offline", done.stderr)

    def test_update_to_a_version_already_on_disk_needs_no_download(self) -> None:
        self.ok("install", "--from", str(self.tarball("2026.11.20")))
        self.ok("update", "--from", str(self.tarball("2026.11.24")))
        self.ok("rollback")
        self.ok("update", FAKE_LATEST="2026.11.24")  # fake curl can't download: it must reuse the dir
        self.assertEqual(self.current(), "2026.11.24")

    def test_rejects_a_tarball_that_isnt_a_release(self) -> None:
        bad = self.tmp / "bad.tar.gz"
        with tarfile.open(bad, "w:gz") as tar:
            tar.add(SCRIPT, arcname="other/file")
        done = self.run_cli("install", "--from", str(bad))
        self.assertEqual(done.returncode, 1)
        self.assertIn("not a dotfiles release", done.stderr)
        self.assertFalse((self.store / "current").exists())

    def test_rollback_without_history(self) -> None:
        self.assertEqual(self.run_cli("rollback").returncode, 1)
        self.ok("install", "--from", str(self.tarball("2026.11.20")))
        done = self.run_cli("rollback")
        self.assertEqual(done.returncode, 1)
        self.assertIn("no previous version", done.stderr)

    def test_check_writes_the_cache_and_is_silent_when_offline(self) -> None:
        state = self.home / ".local" / "state" / "dotfiles"
        self.assertEqual(self.ok("check", "--quiet", FAKE_LATEST=""), "")
        self.assertTrue((state / "checked").exists())
        self.assertFalse((state / "latest").exists())
        self.ok("check", "--quiet", FAKE_LATEST="2026.11.30")
        self.assertEqual((state / "latest").read_text(), "2026.11.30\n")
        self.ok("install", "--from", str(self.tarball("2026.11.24")))
        self.assertIn("2026.11.30 is available (you have 2026.11.24)", self.ok("check", FAKE_LATEST="2026.11.30"))
        self.assertIn("newest release: 2026.11.30", self.ok("status"))


class ReleaseBash32(Release):
    bash = "/bin/bash"


class GitClone(Home):
    def setUp(self) -> None:
        super().setUp()
        self.upstream = self.tmp / "upstream"
        (self.upstream / "bin").mkdir(parents=True)
        shutil.copy(SCRIPT, self.upstream / "bin" / "dotfiles")
        (self.upstream / "install.sh").write_text(STUB_INSTALL.format(code=0))
        (self.upstream / "install.sh").chmod(0o755)
        (self.upstream / "zshrc").write_text("one\n")
        self.git("init", "-q", "-b", "main", cwd=self.upstream)
        self.git("add", ".", cwd=self.upstream)
        self.git("commit", "-q", "-m", "one", cwd=self.upstream)
        self.git("tag", "v2026.11.20", cwd=self.upstream)
        self.clone = self.home / "dotfiles"
        self.git("clone", "-q", str(self.upstream), str(self.clone), cwd=self.tmp)

    def git(self, *args: str, cwd: Path) -> str:
        return subprocess.run(["git", *args], cwd=cwd, env=self.env(), check=True, capture_output=True, text=True).stdout

    def upstream_commit(self, text: str, tag: str = "") -> None:
        (self.upstream / "pins.txt").write_text(text)
        self.git("add", ".", cwd=self.upstream)
        self.git("commit", "-q", "-m", text, cwd=self.upstream)
        if tag:
            self.git("tag", tag, cwd=self.upstream)

    def cli(self, *args: str, **env: str) -> subprocess.CompletedProcess:
        return self.run_cli(*args, script=self.clone / "bin" / "dotfiles", **env)

    def test_pulls_and_reinstalls(self) -> None:
        self.upstream_commit("bump", tag="v2026.11.24")
        done = self.cli("update")
        self.assertEqual(done.returncode, 0, done.stderr)
        self.assertEqual((self.clone / "pins.txt").read_text(), "bump")
        self.assertEqual(self.installs(), ["dotfiles "])
        self.assertIn("dotfiles 2026.11.24: git clone", self.cli("status").stdout)

    def test_up_to_date_runs_nothing(self) -> None:
        done = self.cli("update")
        self.assertEqual(done.returncode, 0)
        self.assertIn("up to date", done.stdout)
        self.assertEqual(self.installs(), [])

    def test_local_changes_stop_it(self) -> None:
        self.upstream_commit("bump")
        (self.clone / "zshrc").write_text("mine\n")
        done = self.cli("update")
        self.assertEqual(done.returncode, 1)
        self.assertIn("local changes", done.stderr)
        self.assertEqual((self.clone / "zshrc").read_text(), "mine\n")
        self.assertFalse((self.clone / "pins.txt").exists())

    def test_diverged_branch_stops_it(self) -> None:
        self.upstream_commit("bot pins")
        (self.clone / "zshrc").write_text("mine\n")
        self.git("commit", "-q", "-am", "mine", cwd=self.clone)
        head = self.git("rev-parse", "HEAD", cwd=self.clone)
        done = self.cli("update")
        self.assertEqual(done.returncode, 1)
        self.assertIn("diverged", done.stderr)
        self.assertIn("pull --rebase", done.stderr)
        self.assertEqual(self.git("rev-parse", "HEAD", cwd=self.clone), head)
        self.assertEqual(self.git("stash", "list", cwd=self.clone), "")


if __name__ == "__main__":
    unittest.main()
