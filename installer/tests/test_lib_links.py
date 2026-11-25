"""install.d/lib.sh link/seed for a release install: links go through `current`, nothing of yours is lost."""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class ReleaseLinks(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.home = self.tmp / "home"
        self.home.mkdir()
        self.store = self.home / ".local" / "share" / "dotfiles"
        self.version = self.store / "2026.11.24"
        shutil.copytree(ROOT / "install.d", self.version / "install.d")
        (self.version / "VERSION").write_text("2026.11.24\n")
        (self.version / "zshrc").write_text("# zshrc\n")
        (self.version / "settings.json").write_text("{}\n")

    def lib(self, snippet: str, version: Path = None) -> str:
        version = version or self.version
        env = {k: v for k, v in os.environ.items() if not k.startswith("DOTFILES")}
        env.update(HOME=str(self.home), NO_COLOR="1")
        done = subprocess.run(["bash", "-c", 'source "$1"; ' + snippet, "-", str(version / "install.d" / "lib.sh")], env=env, capture_output=True, text=True)
        self.assertEqual(done.returncode, 0, done.stderr)
        return done.stdout + done.stderr

    def test_links_go_through_current(self) -> None:
        self.lib('link "$DOTFILES/zshrc" "$HOME/.zshrc"')
        self.assertEqual(os.readlink(self.home / ".zshrc"), str(self.store / "current" / "zshrc"))

    def test_a_link_into_another_version_is_replaced_without_backup(self) -> None:
        (self.home / ".zshrc").symlink_to(self.store / "2026.11.20" / "zshrc")
        self.lib('link "$DOTFILES/zshrc" "$HOME/.zshrc"')
        self.assertEqual(os.readlink(self.home / ".zshrc"), str(self.store / "current" / "zshrc"))
        self.assertFalse((self.home / ".zshrc.bak").exists())

    def test_your_file_is_backed_up(self) -> None:
        (self.home / ".zshrc").write_text("mine\n")
        self.lib('link "$DOTFILES/zshrc" "$HOME/.zshrc"')
        self.assertEqual((self.home / ".zshrc.bak").read_text(), "mine\n")

    def test_seed_keeps_your_settings_and_replaces_an_old_link(self) -> None:
        dst = self.home / ".claude" / "settings.json"
        dst.parent.mkdir()
        dst.write_text('{"mine": true}\n')
        self.lib('seed "$DOTFILES/settings.json" "$HOME/.claude/settings.json"')
        self.assertEqual(dst.read_text(), '{"mine": true}\n')
        dst.unlink()
        dst.symlink_to(self.store / "current" / "settings.json")
        self.lib('seed "$DOTFILES/settings.json" "$HOME/.claude/settings.json"')
        self.assertFalse(dst.is_symlink())
        self.assertEqual(dst.read_text(), "{}\n")

    def test_a_clone_links_straight_into_itself(self) -> None:
        clone = self.tmp / "dotfiles"
        shutil.copytree(ROOT / "install.d", clone / "install.d")
        (clone / "zshrc").write_text("# zshrc\n")
        self.lib('link "$DOTFILES/zshrc" "$HOME/.zshrc"', version=clone)
        self.assertEqual(os.readlink(self.home / ".zshrc"), str(clone / "zshrc"))


if __name__ == "__main__":
    unittest.main()
