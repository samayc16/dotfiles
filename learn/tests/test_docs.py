"""`learn docs` / <leader>lD: reference material, never a side door to the reference solutions."""

from __future__ import annotations

import json
import unittest

from tests.support import IsolatedHome
from learnlib import docs


class TrackReadmeDocsTest(IsolatedHome):
    synthetic = False

    def test_track_readme_docs_list_level_readmes_only(self) -> None:
        for lang in ("shell", "sv"):
            entry = next(e for e in docs.entries_for(lang) if "READMEs" in e.title)
            files = entry.files()
            with self.subTest(lang=lang):
                self.assertGreater(len(files), 10)
                self.assertTrue(all(f.name == "README.md" for f in files), files[:3])
                self.assertFalse(any("solution" in f.parts for f in files))

    def test_json_tells_nvim_which_files_to_offer(self) -> None:
        code, out = self.learn("docs", "shell", "--json")
        self.assertEqual(code, 0, out)
        (entry,) = json.loads(out)
        self.assertTrue(entry["files"])
        self.assertFalse(any("/solution/" in path for path in entry["files"]))

    def test_cli_lists_track_readmes_instead_of_opening_the_track_dir(self) -> None:
        code, out = self.learn("docs", "shell")
        self.assertEqual(code, 0, out)
        self.assertIn("01-first-grep/README.md", out)
        self.assertNotIn("solution", out)


if __name__ == "__main__":
    unittest.main()
