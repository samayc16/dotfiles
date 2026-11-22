import time

from harness import run
from koan import fetch, fetch_all, fetch_grouped, with_timeout


async def test_fetch_all_is_concurrent():
    start = time.perf_counter()
    got = await fetch_all(["a", "b", "c", "d", "e"], 0.1)
    took = time.perf_counter() - start
    assert got == ["A", "B", "C", "D", "E"]
    assert took < 0.3, f"took {took:.2f}s: they ran one after another"


async def test_fetch_grouped():
    start = time.perf_counter()
    assert await fetch_grouped(["x", "y"], 0.1) == ["X", "Y"]
    assert time.perf_counter() - start < 0.25


async def test_with_timeout():
    assert await with_timeout(fetch("fast", 0.01), 1) == "FAST"
    assert await with_timeout(fetch("slow", 1), 0.05) is None


run(globals())
