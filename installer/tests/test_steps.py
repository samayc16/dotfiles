"""Which steps run for a given host, profile and flags."""

import unittest

from installer.host import Host
from installer.steps import STEPS, Selection, plan, unknown_names

MAC = Host("macos", "macOS 26", "arm64", False, False, False)
LINUX = Host("debian", "Debian 12", "x86_64", False, False, False)


def runs(host: Host, selection: Selection) -> list:
    return [step.name for step, reason in plan(host, selection) if not reason]


class Profiles(unittest.TestCase):
    def test_full_on_linux_runs_everything(self) -> None:
        self.assertEqual(runs(LINUX, Selection("full")), [step.name for step in STEPS])

    def test_mac_skips_linux_only_steps(self) -> None:
        ran = runs(MAC, Selection("full"))
        for linux_only in ("mise", "hdl", "swift"):
            self.assertNotIn(linux_only, ran)
        self.assertIn("haskell", ran)

    def test_cli_is_minimal(self) -> None:
        ran = runs(LINUX, Selection("cli"))
        self.assertEqual(ran, ["packages", "fonts", "links", "mise", "zsh", "nvim", "claude"])

    def test_dev_adds_hdl_and_smoke_not_games(self) -> None:
        ran = runs(LINUX, Selection("dev"))
        self.assertIn("hdl", ran)
        self.assertIn("smoke", ran)
        self.assertNotIn("games", ran)


class Flags(unittest.TestCase):
    def test_with_adds_beyond_profile(self) -> None:
        self.assertIn("haskell", runs(LINUX, Selection("cli", extra=frozenset({"haskell"}))))

    def test_skip_removes(self) -> None:
        self.assertNotIn("games", runs(LINUX, Selection("full", skip=frozenset({"games"}))))

    def test_only_overrides_profile_and_platform(self) -> None:
        self.assertEqual(runs(MAC, Selection("cli", only=frozenset({"links", "learn"}))), ["links", "learn"])

    def test_skip_reason_mentions_with(self) -> None:
        reasons = dict((s.name, r) for s, r in plan(LINUX, Selection("cli")))
        self.assertIn("--with games", reasons["games"])

    def test_unknown_names(self) -> None:
        self.assertEqual(unknown_names(frozenset({"nvim", "hdl-src", "gamez"}), frozenset({"hdl-src"})), ["gamez"])


if __name__ == "__main__":
    unittest.main()
