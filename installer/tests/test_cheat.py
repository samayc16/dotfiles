"""The cheatsheets: cheatsheets/*.md, the CHEATSHEET.md built from them, and bin/cheat.

bin/cheat runs under every bash found here (macOS's /bin/bash is 3.2), with stdout piped, so
it never pages or colours.
"""

import importlib.util
import os
import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path
from typing import List

ROOT = Path(__file__).resolve().parents[2]
CHEAT = ROOT / "bin" / "cheat"
_spec = importlib.util.spec_from_file_location("build_cheatsheet", ROOT / "scripts" / "build-cheatsheet.py")
bc = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(bc)

BASHES = sorted({p for p in (shutil.which("bash"), "/bin/bash") if p and os.path.exists(p)})
LINK = re.compile(r"\]\(([^)\s]+)\)")


def headings(path: Path) -> List[str]:
    text = re.sub(r"```.*?```", "", path.read_text(), flags=re.S)
    return [bc.slug(m.group(1)) for m in re.finditer(r"^#+ (.+)$", text, flags=re.M)]


def width(s: str) -> int:
    return len(s)  # every character in the sheets is one column wide, arrows included


class Build(unittest.TestCase):
    def test_checked_in_cheatsheet_is_current(self) -> None:
        self.assertEqual(
            (ROOT / "CHEATSHEET.md").read_text(), bc.build(), "CHEATSHEET.md is stale: run scripts/build-cheatsheet.py"
        )

    def test_every_sheet_is_on_the_combined_page_in_order(self) -> None:
        on_disk = {p.stem for p in (ROOT / "cheatsheets").glob("*.md")}
        self.assertEqual(on_disk, set(bc.ORDER))
        page = bc.build()
        positions = [page.index("\n## " + bc.title(text) + "\n") for _, text in bc.sheets()]
        self.assertEqual(positions, sorted(positions))

    def test_a_sheet_left_out_of_the_order_is_an_error(self) -> None:
        tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, tmp)
        for name in bc.ORDER:
            (tmp / f"{name}.md").write_text(f"# {name}\n")
        (tmp / "extra.md").write_text("# extra\n")
        with self.assertRaises(SystemExit) as raised:
            bc.build(tmp)
        self.assertIn("extra.md is not in ORDER", str(raised.exception))

    def test_headings_move_down_a_level_but_code_does_not(self) -> None:
        text = "# app\n## keys\n```sh\n# a comment\n```\n#notaheading\n"
        self.assertEqual(bc.demote(text), "## app\n### keys\n```sh\n# a comment\n```\n#notaheading")

    def test_links_are_rebased_from_cheatsheets_to_the_repo_root(self) -> None:
        self.assertEqual(bc.RELATIVE_LINK.sub(r"\1", "[a](../docs/x.md) [b](#here) [c](https://x/../y)"),
                         "[a](docs/x.md) [b](#here) [c](https://x/../y)")

    def test_slug_matches_github(self) -> None:
        self.assertEqual(bc.slug("neovim (leader = `Space`)"), "neovim-leader--space")
        self.assertEqual(bc.slug("history, files, processes (atuin, yazi, btop, direnv)"),
                         "history-files-processes-atuin-yazi-btop-direnv")
        self.assertEqual(bc.slug("dotfiles (install & update)"), "dotfiles-install--update")

    def test_every_link_into_or_out_of_the_cheatsheets_resolves(self) -> None:
        sheets = sorted((ROOT / "cheatsheets").glob("*.md"))
        sources = sheets + [ROOT / "CHEATSHEET.md", ROOT / "README.md", *sorted((ROOT / "docs").glob("*.md"))]
        checked = 0
        for source in sources:
            for target in LINK.findall(source.read_text()):
                if target.startswith(("http://", "https://", "mailto:")):
                    continue
                in_scope = source in sheets or source.name == "CHEATSHEET.md" or "cheatsheet" in target.lower()
                if not in_scope:
                    continue
                path, _, anchor = target.partition("#")
                file = (source.parent / path).resolve() if path else source
                self.assertTrue(file.exists(), f"{source.name}: {target} does not exist")
                if anchor:
                    self.assertIn(anchor, headings(file), f"{source.name}: {target} has no such heading")
                checked += 1
        self.assertGreater(checked, 10)


class Cheat(unittest.TestCase):
    def setUp(self) -> None:
        self.bash = BASHES[0]

    def cheat(self, *args: str, sheets: "Path | None" = None, code: int = 0) -> str:
        env = {k: v for k, v in os.environ.items() if k not in ("CHEAT_DIR", "NO_COLOR")}
        if sheets:
            env["CHEAT_DIR"] = str(sheets)
        result = subprocess.run([self.bash, str(CHEAT), *args], capture_output=True, text=True, env=env,
                                stdin=subprocess.DEVNULL, timeout=30)
        self.assertEqual(result.returncode, code, result.stderr)
        return result.stdout if code == 0 else result.stderr

    def fixture(self, text: str) -> Path:
        tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, tmp)
        (tmp / "demo.md").write_text(text)
        return tmp

    def each_bash(self):
        for bash in BASHES:
            with self.subTest(bash=bash):
                self.bash = bash
                yield bash

    def test_list_names_every_sheet_with_its_title(self) -> None:
        for _ in self.each_bash():
            out = self.cheat("--list")
            for name in bc.ORDER:
                self.assertRegex(out, rf"(?m)^  {name} +\S")
            self.assertIn("neovim (leader = Space)", out)  # markdown stripped from titles
            self.assertEqual(self.cheat("--complete").splitlines()[0], "claude:Claude Code")

    def test_without_a_terminal_no_args_lists_the_apps(self) -> None:
        self.assertIn("tmux", self.cheat())

    def test_every_sheet_reads_as_plain_text(self) -> None:
        for _ in self.each_bash():
            for name in bc.ORDER:
                out = self.cheat(name)
                self.assertTrue(out.strip(), name)
                self.assertNotIn("`", out, name)
                self.assertNotIn("**", out, name)
                self.assertNotIn("\x1b", out, name)  # no colour into a pipe
                self.assertNotRegex(out, r"(?m)^\s*\|", name)  # no table syntax left

    def test_keys_line_up_in_a_column(self) -> None:
        for _ in self.each_bash():
            out = self.cheat("tmux").splitlines()
            panes = out[out.index("panes") + 1 : out.index("panes") + 8]
            starts = {len(re.match(r"  (.+?)  +", line).group(0)) for line in panes}
            self.assertEqual(len(starts), 1, panes)

    def test_aliases_open_the_same_sheet(self) -> None:
        self.assertEqual(self.cheat("nvim"), self.cheat("neovim"))
        self.assertEqual(self.cheat("zsh"), self.cheat("shell"))
        self.assertEqual(self.cheat("music"), self.cheat("tamp"))

    def test_words_search_every_app(self) -> None:
        for _ in self.each_bash():
            out = self.cheat("split")
            self.assertRegex(out, r"(?m)^tmux +prefix % or _ +split side-by-side")
            self.assertRegex(out, r"(?m)^neovim ")

    def test_an_app_then_words_searches_that_app_only(self) -> None:
        out = self.cheat("tmux", "session")
        self.assertTrue(out.strip())
        self.assertTrue(all(line.startswith("tmux ") for line in out.splitlines()), out)

    def test_every_word_must_match_in_any_case(self) -> None:
        self.assertIn("prefix X", self.cheat("KILL", "window"))
        self.assertNotIn("prefix x ", self.cheat("kill", "window"))

    def test_words_are_literal_not_patterns(self) -> None:
        self.assertIn("prefix .", self.cheat("tmux", "index"))
        self.cheat("[(.*", code=1)

    def test_nothing_found(self) -> None:
        self.assertIn("nothing mentions 'zzzz'", self.cheat("zzzz", code=1))

    def test_unknown_flag(self) -> None:
        self.cheat("--nope", code=2)

    def test_tables_cells_links_and_pipes(self) -> None:
        sheets = self.fixture(
            "# demo\n\n## keys\n| keys | does |\n|---|---|\n"
            "| `cmd \\| copy` | copy it ([more](../docs/x.md)) |\n"
            "| `Alt-←/→` | **word** jump |\n"
            "| `Alt-h` | left |\n\n"
            "## wide\n| lang | LSP | format |\n|---|---|---|\n| Rust | rust-analyzer | |\n\n"
            "Some prose with `code`.\n\n```\n| not | a table |\n```\n"
        )
        for _ in self.each_bash():
            out = self.cheat("demo", sheets=sheets)
            self.assertIn("cmd | copy", out)
            self.assertIn("copy it (more)", out)
            self.assertIn("word jump", out)
            self.assertIn("Rust  LSP: rust-analyzer", out)  # wide tables name each column; empty cells dropped
            self.assertNotIn("format:", out)
            self.assertIn("Some prose with code.", out)
            self.assertIn("    | not | a table |", out)  # code stays as written
            arrows, letter = (next(line for line in out.splitlines() if key in line) for key in ("Alt-←", "Alt-h"))
            self.assertEqual(width(arrows.split("  word")[0]), width(letter.split("  left")[0]))

    def test_search_reaches_prose_too(self) -> None:
        self.assertIn("focus-minutes", self.cheat("tmux", "focus", "length"))


if __name__ == "__main__":
    unittest.main()
