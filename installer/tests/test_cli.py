"""Argument parsing and an end-to-end dry run of a single step."""

import io
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path

from installer.cli import install_args, main, parse_args, remember_install_args

ROOT = Path(__file__).resolve().parents[2]


class ParseArgs(unittest.TestCase):
    def test_defaults(self) -> None:
        args = parse_args([])
        self.assertEqual(args.profile, "full")
        self.assertFalse(args.dry_run or args.no_sudo)

    def test_lists_and_link_only(self) -> None:
        args = parse_args(["--with", "haskell, games", "--skip", "learn", "--link-only"])
        self.assertEqual(args.extra, frozenset({"haskell", "games"}))
        self.assertEqual(args.skip, frozenset({"learn"}))
        self.assertEqual(args.only, frozenset({"links"}))

    def test_typo_is_an_error(self) -> None:
        with self.assertRaises(SystemExit), redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
            parse_args(["--only", "nvimm"])


class RememberArgs(unittest.TestCase):
    def test_flags_round_trip(self) -> None:
        args = parse_args(["--profile", "cli", "--no-sudo", "--with", "music,hdl", "--skip", "games", "-v"])
        self.assertEqual(install_args(args), ["--profile", "cli", "--with", "hdl,music", "--without", "games", "--no-sudo"])
        self.assertEqual(install_args(parse_args(install_args(args))), install_args(args))

    def test_whole_install_is_recorded(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            remember_install_args(parse_args(["--profile", "dev"]), Path(tmp))
            self.assertEqual((Path(tmp) / "install-args").read_text(), "--profile\ndev\n")

    def test_partial_runs_are_not(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            for argv in (["--only", "nvim"], ["--link-only"], ["--dry-run"]):
                remember_install_args(parse_args(argv), Path(tmp))
            self.assertFalse((Path(tmp) / "install-args").exists())


class DryRun(unittest.TestCase):
    def test_links_dry_run_succeeds(self) -> None:
        out = io.StringIO()
        with redirect_stdout(out):
            code = main(["--only", "links", "--dry-run", "--no-log"], root=ROOT)
        self.assertEqual(code, 0, out.getvalue())
        self.assertIn("links", out.getvalue())

    def test_list_steps(self) -> None:
        out = io.StringIO()
        with redirect_stdout(out):
            self.assertEqual(main(["--list-steps", "--profile", "cli"]), 0)
        self.assertIn("smoke", out.getvalue())


if __name__ == "__main__":
    unittest.main()
