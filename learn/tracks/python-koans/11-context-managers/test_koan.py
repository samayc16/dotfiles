import os
import tempfile
import time

from harness import run
from koan import Timer, working_dir


def test_timer_measures_block():
    with Timer() as t:
        time.sleep(0.05)
    assert 0.04 < t.elapsed < 0.5, f"elapsed={getattr(t, 'elapsed', None)}"


def test_working_dir_switches_and_restores():
    start = os.getcwd()
    with tempfile.TemporaryDirectory() as tmp:
        with working_dir(tmp):
            assert os.path.realpath(os.getcwd()) == os.path.realpath(tmp)
    assert os.getcwd() == start


def test_working_dir_restores_on_error():
    start = os.getcwd()
    with tempfile.TemporaryDirectory() as tmp:
        try:
            with working_dir(tmp):
                raise RuntimeError("boom")
        except RuntimeError:
            pass
    assert os.getcwd() == start, "use try/finally around yield"


run(globals())
