"""scripts/bump-pins.py with every network lookup mocked."""

import importlib.util
import io
import json
import re
import sys
import tempfile
import unittest
import urllib.error
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parents[2]
_spec = importlib.util.spec_from_file_location("bump_pins", ROOT / "scripts" / "bump-pins.py")
bp = importlib.util.module_from_spec(_spec)
sys.modules["bump_pins"] = bp  # dataclasses look their module up by name
_spec.loader.exec_module(bp)

OLD = "a" * 40
NEW = "b" * 40
PINS = """# header comment
# name  kind  source  version
tamp     release  https://github.com/o/tamp  v0.1.0
tmux/tpm commit   https://github.com/tmux-plugins/tpm  %s

# learn
learn/kilo commit https://github.com/antirez/kilo %s
""" % (OLD, OLD)


def run(argv, **lookups):
    out, err = io.StringIO(), io.StringIO()
    with redirect_stdout(out), redirect_stderr(err):
        code = bp.main(argv, **lookups)
    return code, out.getvalue(), err.getvalue()


class Parse(unittest.TestCase):
    def test_pins_and_comments(self) -> None:
        lines = bp.parse(PINS)
        self.assertEqual([p.name for p in bp.pins_of(lines)], ["tamp", "tmux/tpm", "learn/kilo"])
        self.assertEqual(lines[0], "# header comment")

    def test_rejects_bad_lines(self) -> None:
        for text in ("x commit url", "x branch https://github.com/a/b v1", "x commit u a\nx commit u b"):
            with self.assertRaises(bp.PinError):
                bp.parse(text)

    def test_render_aligns_and_round_trips(self) -> None:
        text = bp.render(bp.parse(PINS))
        self.assertEqual(bp.render(bp.parse(text)), text)
        rows = [line for line in text.splitlines() if line.startswith(("tamp", "tmux", "learn/", "# name"))]
        self.assertEqual(len({row.index(row.split()[-1]) for row in rows}), 1, text)  # versions line up
        self.assertIn("# header comment\n", text)

    def test_repo_pins_file_parses(self) -> None:
        lines = bp.load(ROOT / "pins.txt")
        names = [p.name for p in bp.pins_of(lines)]
        self.assertEqual(len([n for n in names if n.startswith("learn/")]), 16)
        self.assertIn("plexamp-tui", names)

    def test_tmux_pins_match_tmux_conf(self) -> None:
        conf = (ROOT / "tmux.conf").read_text()
        plugins = {name.split("/")[1] for name in re.findall(r"^set -g @plugin '([^']+)'", conf, re.M)}
        pinned = {p.name.split("/", 1)[1] for p in bp.pins_of(bp.load(ROOT / "pins.txt")) if p.name.startswith("tmux/")}
        self.assertEqual(plugins, pinned)
        self.assertEqual(len(pinned), 8)


class Bump(unittest.TestCase):
    def test_moves_each_pin_and_reports(self) -> None:
        lines, changes, warnings = bp.bump(bp.parse(PINS), head=lambda url: NEW, release=lambda src: "v0.2.0")
        self.assertEqual([str(c) for c in changes], ["tamp: v0.1.0 → v0.2.0", "tmux/tpm: %s → %s" % (OLD[:12], NEW[:12]), "learn/kilo: %s → %s" % (OLD[:12], NEW[:12])])
        self.assertEqual(warnings, [])
        self.assertTrue(all(p.version in (NEW, "v0.2.0") for p in bp.pins_of(lines)))

    def test_no_release_keeps_pin(self) -> None:
        lines, changes, warnings = bp.bump(bp.parse(PINS), head=lambda url: OLD, release=lambda src: None)
        self.assertEqual(changes, [])
        self.assertEqual(bp.pins_of(lines)[0].version, "v0.1.0")
        self.assertIn("no numbered release", warnings[0])

    def test_failed_lookup_keeps_pin_and_warns(self) -> None:
        def broken(url):
            raise bp.PinError("network down")

        lines, changes, warnings = bp.bump(bp.parse(PINS), head=broken, release=lambda src: "v0.1.0")
        self.assertEqual(changes, [])
        self.assertEqual(len(warnings), 2)
        self.assertIn("network down", warnings[0])

    def test_command_rewrites_file_and_writes_changes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            pins, changes = Path(tmp) / "pins.txt", Path(tmp) / "changes.txt"
            pins.write_text(PINS)
            code, out, _ = run(["bump", "--pins", str(pins), "--changes", str(changes)], head=lambda url: NEW, release=lambda src: "v0.1.0")
            self.assertEqual(code, 0)
            self.assertEqual(out, changes.read_text())
            self.assertEqual(out.count("→"), 2)
            self.assertEqual(sum(p.version == NEW for p in bp.pins_of(bp.load(pins))), 2)

    def test_command_when_nothing_moves(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            pins = Path(tmp) / "pins.txt"
            pins.write_text(PINS)
            code, out, _ = run(["bump", "--pins", str(pins)], head=lambda url: OLD, release=lambda src: "v0.1.0")
            self.assertEqual((code, out.strip()), (0, "every pin is already the newest"))


class Lookups(unittest.TestCase):
    def test_git_head_parses_ls_remote(self) -> None:
        done = mock.Mock(stdout="%s\tHEAD\n" % NEW)
        with mock.patch.object(bp.subprocess, "run", return_value=done) as run_:
            self.assertEqual(bp.git_head("https://github.com/a/b"), NEW)
        self.assertEqual(run_.call_args.args[0], ["git", "ls-remote", "https://github.com/a/b", "HEAD"])

    def test_git_head_failure_is_a_pin_error(self) -> None:
        with mock.patch.object(bp.subprocess, "run", side_effect=bp.subprocess.CalledProcessError(128, "git", stderr="not found")):
            with self.assertRaises(bp.PinError):
                bp.git_head("https://github.com/a/b")

    def _respond(self, payload):
        response = mock.MagicMock()
        response.__enter__.return_value = io.BytesIO(json.dumps(payload).encode())
        return response

    def test_latest_release_uses_token_and_accepts_numbered_tags(self) -> None:
        with mock.patch.object(bp.urllib.request, "urlopen", return_value=self._respond({"tag_name": "v1.2.3"})) as urlopen:
            self.assertEqual(bp.latest_release("https://github.com/samayc16/plexamp-tui", "tok"), "v1.2.3")
        request = urlopen.call_args.args[0]
        self.assertEqual(request.full_url, "https://api.github.com/repos/samayc16/plexamp-tui/releases/latest")
        self.assertEqual(request.get_header("Authorization"), "Bearer tok")

    def test_latest_release_ignores_unnumbered_tags(self) -> None:
        with mock.patch.object(bp.urllib.request, "urlopen", return_value=self._respond({"tag_name": "edge"})):
            self.assertIsNone(bp.latest_release("https://github.com/o/r"))

    def test_latest_release_404_means_none(self) -> None:
        error = urllib.error.HTTPError("u", 404, "Not Found", {}, io.BytesIO())
        with mock.patch.object(bp.urllib.request, "urlopen", side_effect=error):
            self.assertIsNone(bp.latest_release("https://github.com/o/r"))

    def test_latest_release_rate_limit_is_a_pin_error(self) -> None:
        error = urllib.error.HTTPError("u", 403, "Forbidden", {}, io.BytesIO())
        with mock.patch.object(bp.urllib.request, "urlopen", side_effect=error):
            with self.assertRaises(bp.PinError):
                bp.latest_release("https://github.com/o/r")

    def test_asset_url(self) -> None:
        payload = {"assets": [{"name": "x.tar.gz", "browser_download_url": "u1"}, {"name": "x-0.1.0-py3-none-any.whl", "browser_download_url": "u2"}]}
        with mock.patch.object(bp.urllib.request, "urlopen", return_value=self._respond(payload)) as urlopen:
            self.assertEqual(bp.asset_url(bp.parse(PINS), "tamp", "*.whl", None), "u2")
        self.assertTrue(urlopen.call_args.args[0].full_url.endswith("/repos/o/tamp/releases/tags/v0.1.0"))
        with self.assertRaises(bp.PinError):
            bp.asset_url(bp.parse(PINS), "tmux/tpm", "*.whl", None)


class DiffAndTable(unittest.TestCase):
    def test_diff(self) -> None:
        new = PINS.replace("learn/kilo commit https://github.com/antirez/kilo " + OLD, "learn/kilo commit https://github.com/antirez/kilo " + NEW)
        new += "extra commit https://github.com/a/b %s\n" % NEW
        changes = bp.diff(bp.parse(PINS), bp.parse(new.replace("tamp     release  https://github.com/o/tamp  v0.1.0\n", "")))
        self.assertEqual([str(c) for c in changes], ["learn/kilo: %s → %s" % (OLD[:12], NEW[:12]), "extra: (new) → %s" % NEW[:12], "tamp: v0.1.0 → (removed)"])

    def test_table(self) -> None:
        self.assertEqual(bp.table(bp.parse(PINS)).splitlines()[0].split(), ["tamp", "v0.1.0"])


if __name__ == "__main__":
    unittest.main()
