"""learnlib: exercise.json "support" files, the read-only copies a workspace gets refreshed.

Run from the repo root: python3 -m unittest discover -s learn/tests -t learn
"""

from __future__ import annotations

import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from learnlib import docs, tracks, workspace

TESTS_RS = "#[test]\nfn t() {}\n"


class SupportFilesTest(unittest.TestCase):
    def setUp(self) -> None:
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        root = Path(tmp.name)
        self.ex_dir = root / "tracks" / "demo" / "01-x"
        (self.ex_dir / "tests").mkdir(parents=True)
        (self.ex_dir / "lib.rs").write_text("starter\n")
        (self.ex_dir / "Cargo.toml").write_text("[package]\n")
        (self.ex_dir / "tests" / "checks.rs").write_text(TESTS_RS)
        self.write_meta(support=["Cargo.toml", "tests/checks.rs"])
        patcher = mock.patch.object(workspace, "WORKSPACE_ROOT", root / "workspace")
        patcher.start()
        self.addCleanup(patcher.stop)

    def write_meta(self, **extra: object) -> None:
        meta = {"title": "X", "files": ["lib.rs"], **extra}
        (self.ex_dir / "exercise.json").write_text(json.dumps(meta))

    def load(self) -> tuple:
        with mock.patch.object(tracks.ui, "warn") as warn:
            exercise = tracks.load_exercise("demo", "rust", self.ex_dir)
        return exercise, warn

    def test_support_paths_are_loaded(self) -> None:
        exercise, warn = self.load()
        self.assertEqual(exercise.extra["support"], ("Cargo.toml", "tests/checks.rs"))
        warn.assert_not_called()

    def test_paths_leaving_the_exercise_are_dropped_with_a_warning(self) -> None:
        self.write_meta(support=["Cargo.toml", "../escape.txt", "/etc/hosts", "a/../../b", ""])
        exercise, warn = self.load()
        self.assertEqual(exercise.extra["support"], ("Cargo.toml",))
        warn.assert_called_once()

    def test_exercises_without_support_load_as_before(self) -> None:
        self.write_meta()
        exercise, warn = self.load()
        self.assertEqual(exercise.extra["support"], ())
        warn.assert_not_called()

    def test_prepare_copies_support_files_but_does_not_open_them(self) -> None:
        exercise, _ = self.load()
        ws = workspace.prepare(exercise)
        self.assertEqual((ws / "Cargo.toml").read_text(), "[package]\n")
        self.assertEqual((ws / "tests" / "checks.rs").read_text(), TESTS_RS)
        self.assertEqual(exercise.files, ("lib.rs",))

    def test_prepare_restores_edited_support_files_and_keeps_learner_edits(self) -> None:
        exercise, _ = self.load()
        ws = workspace.prepare(exercise)
        (ws / "tests" / "checks.rs").write_text("tampered\n")
        (ws / "lib.rs").write_text("my work\n")
        workspace.prepare(exercise)
        self.assertEqual((ws / "tests" / "checks.rs").read_text(), TESTS_RS)
        self.assertEqual((ws / "lib.rs").read_text(), "my work\n")

    def test_unchanged_support_files_are_not_rewritten(self) -> None:
        exercise, _ = self.load()
        ws = workspace.prepare(exercise)
        cargo_toml = ws / "Cargo.toml"
        os.utime(cargo_toml, (1_000_000, 1_000_000))
        workspace.prepare(exercise)
        self.assertEqual(cargo_toml.stat().st_mtime, 1_000_000)


class RustDocsTest(unittest.TestCase):
    def test_rust_docs_are_registered_with_an_alias(self) -> None:
        titles = [entry.title for entry in docs.entries_for("rs") or []]
        self.assertEqual(
            titles, ["The Rust Programming Language (book)", "Rust standard library", "Rust by Example"]
        )

    def test_missing_rustc_reports_docs_as_missing(self) -> None:
        with mock.patch.object(docs.shutil, "which", return_value=None), mock.patch.object(
            docs.Path, "exists", return_value=False
        ):
            entries = docs.entries_for("rust") or []
        self.assertTrue(entries)
        self.assertTrue(all(not entry.exists for entry in entries))


if __name__ == "__main__":
    unittest.main()
