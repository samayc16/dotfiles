import io
import tempfile
from pathlib import Path

from harness import run
from koan import count_lines, longest_line, read_chunks


def test_count_lines():
    with tempfile.TemporaryDirectory() as tmp:
        folder = Path(tmp)
        (folder / "a.txt").write_text("1\n2\n3\n")
        (folder / "b.txt").write_text("x\n")
        (folder / "c.log").write_text("ignored\n")
        assert count_lines(folder) == 4
        assert count_lines(folder, "*.log") == 1


def test_longest_line():
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "f.txt"
        path.write_text("ab\nabcd\nabc\n")
        assert longest_line(path) == "abcd"


def test_read_chunks():
    assert list(read_chunks(io.StringIO("abcdefg"), 3)) == ["abc", "def", "g"]


run(globals())
