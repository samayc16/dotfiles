"""Unsaved edits: `learn check` reads the file on disk, so it must say when the editor holds newer text.

Vim and Neovim keep a swap file per open buffer whose first block records the editing process
and a "modified" flag; that's how `learn check` (run from a terminal or by an assistant) can tell.
"""

from __future__ import annotations

import os
import subprocess
import sys
import unittest
from pathlib import Path
from unittest import mock

from tests.support import IsolatedHome
from learnlib import workspace


def swap_block0(pid: int, dirty: bool, fname: str) -> bytes:
    """Block 0 of a Vim/Neovim swap file (memline.c `struct block0`), as far as learn reads it."""
    block = bytearray(4096)
    block[0:2] = b"b0"
    block[2:12] = b"VIM 8.1".ljust(10, b"\0")
    block[12:16] = (4096).to_bytes(4, "little")
    block[24:28] = pid.to_bytes(4, "little")
    name = fname.encode()[:899]
    block[108 : 108 + len(name)] = name
    block[1007] = 0x55 if dirty else 0
    return bytes(block)


def dead_pid() -> int:
    proc = subprocess.Popen([sys.executable, "-c", "pass"])
    proc.wait()
    return proc.pid


class UnsavedFilesTest(IsolatedHome):
    def setUp(self) -> None:
        super().setUp()
        self.swap_dir = self.home / "state" / "nvim" / "swap"
        self.swap_dir.mkdir(parents=True)
        patcher = mock.patch.object(workspace, "SWAP_DIRS", (self.swap_dir,))
        patcher.start()
        self.addCleanup(patcher.stop)
        self.workspace = self.start()
        self.exercise = workspace_exercise()

    def nvim_swap(self, pid: int, dirty: bool, suffix: str = ".swp") -> Path:
        target = self.workspace / "answer.txt"
        path = self.swap_dir / (str(target).replace(os.sep, "%") + suffix)
        path.write_bytes(swap_block0(pid, dirty, str(target)))
        return path

    def test_a_modified_buffer_in_a_running_nvim_is_reported(self) -> None:
        self.nvim_swap(os.getpid(), dirty=True)
        self.assertEqual(workspace.unsaved_files(self.exercise, self.workspace), ["answer.txt"])

    def test_a_second_swap_file_for_the_same_buffer_is_found_too(self) -> None:
        self.nvim_swap(os.getpid(), dirty=True, suffix=".swo")
        self.assertEqual(workspace.unsaved_files(self.exercise, self.workspace), ["answer.txt"])

    def test_vim_swap_files_next_to_the_file_count(self) -> None:
        swap = self.workspace / ".answer.txt.swp"
        swap.write_bytes(swap_block0(os.getpid(), True, str(self.workspace / "answer.txt")))
        self.assertEqual(workspace.unsaved_files(self.exercise, self.workspace), ["answer.txt"])

    def test_saved_buffers_and_crashed_editors_are_not_reported(self) -> None:
        self.nvim_swap(os.getpid(), dirty=False)
        self.nvim_swap(dead_pid(), dirty=True, suffix=".swo")
        (self.swap_dir / "garbage.swp").write_bytes(b"not a swap file")
        self.assertEqual(workspace.unsaved_files(self.exercise, self.workspace), [])

    def test_check_warns_and_does_not_count_a_check_of_stale_text(self) -> None:
        (self.workspace / "answer.txt").write_text("half done\n")
        self.nvim_swap(os.getpid(), dirty=True)
        code, out = self.learn("check", cwd=self.workspace)
        self.assertEqual(code, 1, out)
        self.assertIn("answer.txt has unsaved changes in your editor", out)
        self.assertIn(":w", out)
        self.assertEqual(self.entry("demo/01-ex")["attempts"], 0)


def workspace_exercise():
    from learnlib import tracks

    return tracks.resolve(tracks.load_all(), "demo/01-ex")


class DefaultSwapDirsTest(unittest.TestCase):
    def test_neovim_state_dir_follows_xdg_and_appname(self) -> None:
        env = {"XDG_STATE_HOME": "/x/state", "NVIM_APPNAME": "nv"}
        with mock.patch.dict(os.environ, env):
            self.assertIn(Path("/x/state/nv/swap"), workspace.default_swap_dirs())
        with mock.patch.dict(os.environ, {}, clear=True), mock.patch.object(Path, "home", return_value=Path("/h")):
            self.assertIn(Path("/h/.local/state/nvim/swap"), workspace.default_swap_dirs())


if __name__ == "__main__":
    unittest.main()
