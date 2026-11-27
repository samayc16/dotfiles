"""nvim/lua/plugins/learn.lua driven for real: a headless Neovim, steered over its RPC socket.

Each test starts `nvim --headless --clean` with tests/nvim/init.lua (the learn spec and nothing
else) in a temp LEARN_HOME and temp XDG dirs, presses the real <leader>l keys, and reads the
editor's state back. Skipped when nvim (0.10+) isn't installed.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import tempfile
import time
import unittest
from pathlib import Path
from typing import Callable

from tests.support import REPO, run_cli

NVIM = shutil.which("nvim")
INIT = Path(__file__).resolve().parent / "nvim" / "init.lua"
LEARN_LUA = REPO / "nvim" / "lua" / "plugins" / "learn.lua"
SHELL = REPO / "learn" / "tracks" / "shell"
FIRST = "shell/01-first-grep"


def nvim_is_recent() -> bool:
    if NVIM is None:
        return False
    out = subprocess.run([NVIM, "--version"], stdout=subprocess.PIPE, universal_newlines=True).stdout
    major, minor = (int(part) for part in out.split()[1].lstrip("v").split(".")[:2])
    return (major, minor) >= (0, 10)


@unittest.skipUnless(nvim_is_recent(), "needs Neovim 0.10+")
class LearnInNvimTest(unittest.TestCase):
    def setUp(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = root = Path(tmp.name).resolve()
        self.home = root / "learn"
        self.sock = "./nvim.sock"  # relative to root, as a long TMPDIR overflows the 104-byte socket path limit
        self.env = {k: v for k, v in os.environ.items() if k not in ("NO_COLOR", "LEARN_FORCE_COLOR", "NVIM")}
        self.env.update(
            LEARN_HOME=str(self.home),
            LEARN_LUA=str(LEARN_LUA),
            PATH=f"{REPO / 'bin'}{os.pathsep}{os.environ.get('PATH', '')}",
            SHELL=shutil.which("bash") or "/bin/sh",
            **{f"XDG_{kind}_HOME": str(root / kind.lower()) for kind in ("CONFIG", "DATA", "STATE", "CACHE")},
        )
        self.nvim = subprocess.Popen(
            [NVIM, "--headless", "--clean", "--listen", self.sock, "-c", f"luafile {INIT}"],
            cwd=str(root),
            env=self.env,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        self.addCleanup(self.stop)
        self.wait_for(lambda: (root / self.sock).exists() and self.expr("1") == "1", "nvim to listen", timeout=20)
        self.wait_for(lambda: self.expr("exists('*v:lua.T.state')") != "", "init.lua")

    def stop(self) -> None:
        self.nvim.kill()
        self.nvim.wait(timeout=10)

    # ── talking to nvim ─────────────────────────────────────────────────────

    def remote(self, flag: str, arg: str) -> str:
        proc = subprocess.run(
            [NVIM, "--server", self.sock, flag, arg],
            cwd=str(self.root),
            env=self.env,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            timeout=30,
        )
        return proc.stdout.strip()

    def expr(self, expression: str) -> str:
        return self.remote("--remote-expr", expression)

    def keys(self, keys: str) -> None:
        self.remote("--remote-send", keys)

    def state(self) -> dict:
        return json.loads(self.expr("v:lua.T.state()"))

    def wait_for(self, ready: Callable[[], bool], what: str, timeout: float = 60) -> None:
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                if ready():
                    return
            except (ValueError, subprocess.SubprocessError, OSError):
                pass
            time.sleep(0.1)
        try:
            state = self.state()
        except (ValueError, subprocess.SubprocessError, OSError) as exc:
            state = f"unavailable ({exc})"
        self.fail(f"timed out waiting for {what}; state: {state}")

    def progress(self) -> dict:
        saved = self.home / "progress.json"
        return json.loads(saved.read_text())["exercises"] if saved.exists() else {}

    def open_first(self) -> dict:
        self.keys(f":Learn {FIRST}<CR>")
        ws = self.home / "workspace" / FIRST
        self.wait_for(lambda: self.state()["current"] == str(ws / "solution.sh"), "the exercise to open")
        return self.state()

    def type_solution(self) -> None:
        self.expr(f"v:lua.T.type_in('{SHELL / '01-first-grep' / 'solution' / 'solution.sh'}')")

    # ── tests ───────────────────────────────────────────────────────────────

    def test_open_shows_the_code_with_the_readme_beside_it(self) -> None:
        state = self.open_first()
        ws = self.home / "workspace" / FIRST
        self.assertEqual(state["cwd"], str(ws))
        readme = [w for w in state["wins"] if w["name"] == str(ws / "README.md")]
        self.assertEqual(len(readme), 1, state["wins"])
        self.assertTrue(readme[0]["readonly"])
        self.assertFalse(readme[0]["listed"])
        self.keys(" lr")
        self.wait_for(lambda: len(self.state()["wins"]) == 1, "<leader>lr to close the README")
        self.keys(" lr")
        self.wait_for(lambda: len(self.state()["wins"]) == 2, "<leader>lr to reopen it")

    def test_check_saves_first_then_pass_and_move_on(self) -> None:
        self.open_first()
        self.type_solution()
        self.assertTrue(self.state()["modified"])
        self.keys(" lc")
        self.wait_for(lambda: self.progress().get(FIRST, {}).get("passed"), "<leader>lc to pass", timeout=120)
        self.keys(" ln")
        nxt = self.home / "workspace" / "shell" / "02-ignore-case" / "solution.sh"
        self.wait_for(lambda: self.state()["current"] == str(nxt), "<leader>ln to open the next one")
        listed = self.state()["listed"]
        self.assertNotIn(str(self.home / "workspace" / FIRST / "solution.sh"), listed)
        self.keys(" lp")
        self.wait_for(lambda: self.state()["current"].endswith("01-first-grep/solution.sh"), "<leader>lp")

    def test_solution_opens_in_its_own_tab_only_after_passing(self) -> None:
        self.open_first()
        self.keys(" ls")
        self.wait_for(lambda: any("unlock" in n["msg"] for n in self.state()["notes"]), "the locked notice")
        self.assertEqual(self.state()["tabs"], 1)
        self.type_solution()
        self.keys(" lc")
        self.wait_for(lambda: self.progress().get(FIRST, {}).get("passed"), "the pass", timeout=120)
        self.keys(" ls")
        self.wait_for(lambda: self.state()["tabs"] == 2, "the solution tab")
        state = self.state()
        self.assertTrue(state["current"].endswith("01-first-grep/solution/solution.sh"), state["current"])
        self.assertFalse(any(name == "" for name in state["listed"]), "an empty [No Name] buffer was left behind")

    def test_prev_at_the_first_exercise_is_a_notice_not_a_decode_error(self) -> None:
        self.open_first()
        self.keys(" lp")
        self.wait_for(lambda: self.state()["notes"][1:], "a notice")
        messages = " ".join(n["msg"] for n in self.state()["notes"])
        self.assertIn("first exercise", messages)
        self.assertNotIn("unexpected output", messages)

    def test_hint_float_warns_that_it_costs_stars(self) -> None:
        self.open_first()
        self.keys(" lh")
        self.wait_for(lambda: any(w["float"] for w in self.state()["wins"]), "the hint float")
        text = next(w["text"] for w in self.state()["wins"] if w["float"])
        self.assertIn("Hint 1/", text)
        self.assertIn("caps this exercise at ★", text)

    def test_learn_check_outside_nvim_reports_unsaved_edits(self) -> None:
        self.open_first()
        self.type_solution()  # typed, not saved: the real-use trap
        ws = self.home / "workspace" / FIRST
        self.wait_for(lambda: list((self.home.parent / "state").rglob("*solution.sh.sw?")), "the swap file")
        proc = run_cli(["check"], self.home, cwd=ws, env={"XDG_STATE_HOME": self.env["XDG_STATE_HOME"]})
        self.assertEqual(proc.returncode, 1)
        self.assertIn("solution.sh has unsaved changes in your editor", proc.stderr)
        self.assertIn("not counted", proc.stdout)

    def test_shell_docs_offer_level_readmes_and_no_solutions(self) -> None:
        self.keys(":Learn docs shell<CR>")
        self.wait_for(lambda: self.state()["offered"], "the docs picker")
        offered = self.state()["offered"]
        self.assertGreater(len(offered), 10)
        self.assertTrue(all(path.endswith("/README.md") for path in offered), offered[:3])


if __name__ == "__main__":
    unittest.main()
