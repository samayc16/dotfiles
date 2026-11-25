"""install.d/music.sh picks the right plexamp-tui source and never replaces a dev install.

Runs the real step from a copy of the repo with fake `uv`, `mpv` and `tamp` on PATH that only
record what they were asked to do.
"""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FAKE_UV = """#!/bin/sh
echo "uv $*" >>"$HOME/calls.log"
[ "$1 $2" = "tool list" ] && cat "$HOME/tool-list" 2>/dev/null
exit 0
"""
FAKE_TAMP = "#!/bin/sh\necho 'tamp 0.1.0'\n"


class MusicStep(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.repo = self.tmp / "repo"
        shutil.copytree(ROOT / "install.d", self.repo / "install.d")
        self.pins = self.repo / "pins.txt"
        self.pins.write_text("plexamp-tui release https://github.com/samayc16/plexamp-tui v0.2.0\n")
        self.home = self.tmp / "home"
        self.home.mkdir()
        bindir = self.tmp / "bin"
        bindir.mkdir()
        for name, text in (("uv", FAKE_UV), ("tamp", FAKE_TAMP), ("mpv", "#!/bin/sh\n")):
            (bindir / name).write_text(text)
            (bindir / name).chmod(0o755)
        self.env = {k: v for k, v in os.environ.items() if not k.startswith(("XDG_", "UV_"))}
        self.env.update(HOME=str(self.home), PATH="%s:/usr/bin:/bin" % bindir, NO_COLOR="1", NO_SUDO="1", DRY_RUN="0")

    def run_step(self) -> str:
        done = subprocess.run(["bash", str(self.repo / "install.d" / "music.sh")], env=self.env, capture_output=True, text=True)
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
        return done.stdout + done.stderr

    def installs(self) -> list:
        log = self.home / "calls.log"
        return [line for line in log.read_text().splitlines() if line.startswith("uv tool install")] if log.exists() else []

    def test_pinned_release_wheel(self) -> None:
        self.run_step()
        self.assertEqual(self.installs(), ["uv tool install --upgrade --quiet --no-build-package pillow https://github.com/samayc16/plexamp-tui/releases/download/v0.2.0/plexamp_tui-0.2.0-py3-none-any.whl"])

    def test_bundled_wheel_wins(self) -> None:
        wheel = self.repo / "dist" / "plexamp_tui-0.2.0-py3-none-any.whl"
        wheel.parent.mkdir()
        wheel.write_text("")
        self.run_step()
        self.assertEqual(self.installs(), ["uv tool install --upgrade --quiet --no-build-package pillow %s" % wheel])

    def test_no_release_yet_installs_main(self) -> None:
        self.pins.write_text("plexamp-tui release https://github.com/samayc16/plexamp-tui -\n")
        self.assertIn("no numbered", self.run_step())
        self.assertEqual(self.installs(), ["uv tool install --upgrade --quiet --no-build-package pillow git+https://github.com/samayc16/plexamp-tui"])

    def test_editable_dev_install_is_left_alone(self) -> None:
        receipt = self.home / ".local" / "share" / "uv" / "tools" / "plexamp-tui" / "uv-receipt.toml"
        receipt.parent.mkdir(parents=True)
        receipt.write_text('[tool]\nrequirements = [{ name = "plexamp-tui", editable = "/src/plexamp-tui" }]\n')
        self.assertIn("dev install, left alone", self.run_step())
        self.assertEqual(self.installs(), [])

    def test_regular_install_is_upgraded(self) -> None:
        receipt = self.home / ".local" / "share" / "uv" / "tools" / "plexamp-tui" / "uv-receipt.toml"
        receipt.parent.mkdir(parents=True)
        receipt.write_text('[tool]\nrequirements = [{ name = "plexamp-tui", url = "https://x/plexamp_tui-0.1.0-py3-none-any.whl" }]\n')
        self.run_step()
        self.assertEqual(len(self.installs()), 1)

    def test_old_tamp_tool_is_removed_first(self) -> None:
        (self.home / "tool-list").write_text("tamp v0.0.9\n- tamp\n")
        self.run_step()
        calls = (self.home / "calls.log").read_text()
        self.assertLess(calls.index("uv tool uninstall tamp"), calls.index("uv tool install"))


if __name__ == "__main__":
    unittest.main()
