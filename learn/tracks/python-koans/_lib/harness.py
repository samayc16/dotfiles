"""Tiny koan runner: executes every test_* function in definition order.

Prints ✓/✗ per check and exits non-zero if any fail. Async tests are awaited.
"""

from __future__ import annotations

import asyncio
import inspect
import os
import sys

GREEN, RED, GRAY, RESET = ("\033[38;2;169;220;118m", "\033[38;2;255;97;136m", "\033[38;2;114;112;114m", "\033[0m")
if os.environ.get("NO_COLOR"):
    GREEN = RED = GRAY = RESET = ""


def _pretty(name: str) -> str:
    return name.removeprefix("test_").replace("_", " ")


def run(namespace: dict) -> None:
    tests = [(n, f) for n, f in namespace.items() if n.startswith("test_") and inspect.isfunction(f)]
    tests.sort(key=lambda item: item[1].__code__.co_firstlineno)
    failed = 0
    for name, fn in tests:
        try:
            result = fn()
            if inspect.iscoroutine(result):
                asyncio.run(result)
            print(f"  {GREEN}✓{RESET} {_pretty(name)}")
        except NotImplementedError as exc:
            failed += 1
            print(f"  {RED}✗{RESET} {_pretty(name)} {GRAY}— not implemented yet{': ' + str(exc) if str(exc) else ''}{RESET}")
        except AssertionError as exc:
            failed += 1
            print(f"  {RED}✗{RESET} {_pretty(name)} {GRAY}— {exc or 'assertion failed'}{RESET}")
        except Exception as exc:  # noqa: BLE001 - report any learner error as a failed koan
            failed += 1
            print(f"  {RED}✗{RESET} {_pretty(name)} {GRAY}— {type(exc).__name__}: {exc}{RESET}")
    passed = len(tests) - failed
    print(f"\n  {passed}/{len(tests)} checks passing")
    sys.exit(1 if failed else 0)
