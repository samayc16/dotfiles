"""install.d/libc.sh: which Neovim, Node and Python a Linux system can run without root.

Each case sources lib.sh and libc.sh under `set -euo pipefail` (as the steps do) with getconf,
ldconfig, uname and python3 replaced by shell functions that describe a system.
"""

import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASHES = sorted({p for p in (shutil.which("bash"), "/bin/bash") if p and Path(p).exists()})

MUSL = "getconf() { return 1; }; ldconfig() { return 1; }"


def glibc(version: str, libatomic: bool = True, arch: str = "x86_64") -> str:
    libs = "libatomic.so.1 (libc6,x86-64) => /lib64/libatomic.so.1" if libatomic else "libc.so.6 (libc6,x86-64) => /lib64/libc.so.6"
    return (
        f'getconf() {{ [ "$1" = GNU_LIBC_VERSION ] && echo "glibc {version}"; }}; '
        f'ldconfig() {{ echo "1 libs found in cache"; echo "  {libs}"; }}; '
        f'uname() {{ [ "$1" = -m ] && echo {arch} || command uname "$@"; }}'
    )


class Libc(unittest.TestCase):
    def ask(self, system: str, question: str, bash: str = "") -> bool:
        script = (
            "set -euo pipefail\n"
            f'source "{ROOT}/install.d/lib.sh" >/dev/null\n'
            f'source "{ROOT}/install.d/libc.sh"\n'
            f"{system}\n"
            f"if {question}; then echo yes; else echo no; fi\n"
        )
        result = subprocess.run([bash or BASHES[0], "-c", script], capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip().splitlines()[-1] == "yes"

    def test_glibc_version_is_empty_on_musl_and_never_ends_the_step(self) -> None:
        for bash in BASHES:
            with self.subTest(bash=bash):
                # a plain assignment, as the steps do: errexit is off inside `if`, so asking there proves nothing
                self.assertTrue(self.ask(MUSL + '; glibc="$(glibc_version)"', '[[ -z "$glibc" ]]', bash))

    def test_neovim(self) -> None:
        cases = {
            "Alpine (musl): skipped elsewhere, never the glibc build": (MUSL, False),
            "Ubuntu 20.04 (glibc 2.31)": (glibc("2.31"), True),
            "Rocky 8 (glibc 2.28)": (glibc("2.28", libatomic=False), True),
            "Rocky 9 (glibc 2.34)": (glibc("2.34"), False),
            "Ubuntu 24.04 (glibc 2.39)": (glibc("2.39"), False),
        }
        for name, (system, wanted) in cases.items():
            with self.subTest(name):
                self.assertEqual(self.ask(system, "wants_old_glibc_nvim"), wanted)

    def test_node(self) -> None:
        cases = {
            "Alpine (musl): musl build elsewhere": (MUSL, False),
            "Rocky 8 minimal: no libatomic": (glibc("2.28", libatomic=False), True),
            "Rocky 9 minimal: no libatomic": (glibc("2.34", libatomic=False), True),
            "Amazon Linux 2: glibc 2.26": (glibc("2.26"), True),
            "Ubuntu 20.04 with libatomic": (glibc("2.31"), False),
            "arm64 without libatomic: no glibc 2.17 build to use": (glibc("2.28", libatomic=False, arch="aarch64"), False),
        }
        for name, (system, wanted) in cases.items():
            with self.subTest(name):
                self.assertEqual(self.ask(system, "wants_glibc217_node"), wanted)

    def test_git(self) -> None:
        cases = {
            "none installed": ("hash -r; PATH=/nonexistent", False),
            "CentOS 7: 1.8.3.1": ('git() { echo "git version 1.8.3.1"; }', False),
            "2.18.5: one short of partial clones": ('git() { echo "git version 2.18.5"; }', False),
            "2.19.0": ('git() { echo "git version 2.19.0"; }', True),
            "Apple's: 2.50.1 (Apple Git-155)": ('git() { echo "git version 2.50.1 (Apple Git-155)"; }', True),
        }
        for name, (system, wanted) in cases.items():
            with self.subTest(name):
                self.assertEqual(self.ask(system, "git_ok"), wanted)
        self.assertTrue(self.ask('hash -r; PATH=/nonexistent; v="$(git_version)"', '[[ -z "$v" ]]'))  # no git ends nothing

    def test_python(self) -> None:
        cases = {
            "none installed": ("hash -r; PATH=/nonexistent", False),
            "3.6 (RHEL 8's platform python)": ("python3() { return 1; }", False),
            "3.12 without ensurepip (Debian without python3-venv)": ("python3() { return 1; }", False),
            "3.12 with venv": ("python3() { return 0; }", True),
        }
        for name, (system, wanted) in cases.items():
            with self.subTest(name):
                self.assertEqual(self.ask(system, "python_ok"), wanted)  # a python3 function counts as installed


if __name__ == "__main__":
    unittest.main()
