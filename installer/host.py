"""What machine are we on? OS family, distro, architecture and privileges."""

from __future__ import annotations

import os
import platform
import shutil
import subprocess
from dataclasses import dataclass
from typing import Dict

# os-release ID / ID_LIKE words → package-manager family
FAMILIES = {
    "arch": ("arch", "manjaro", "endeavouros", "cachyos"),
    "debian": ("debian", "ubuntu", "linuxmint", "pop"),
    "rhel": ("fedora", "rhel", "centos", "rocky", "almalinux", "ol", "amzn"),
    "suse": ("opensuse", "opensuse-leap", "opensuse-tumbleweed", "suse", "sles"),
}


@dataclass(frozen=True)
class Host:
    os: str  # macos | arch | debian | rhel | suse | linux | unknown
    distro: str  # human-readable, e.g. "Ubuntu 24.04.1 LTS"
    arch: str  # x86_64 | arm64 | aarch64 …
    is_root: bool
    can_sudo: bool  # passwordless/cached sudo works right now
    wsl: bool

    @property
    def is_mac(self) -> bool:
        return self.os == "macos"

    @property
    def is_linux(self) -> bool:
        return self.os not in ("macos", "unknown")

    @property
    def can_install_system(self) -> bool:
        """Homebrew needs no root; Linux package managers need root or sudo."""
        return self.is_mac or self.is_root or self.can_sudo


def parse_os_release(text: str) -> Dict[str, str]:
    values = {}
    for line in text.splitlines():
        key, sep, value = line.partition("=")
        if sep and key.strip() and not key.startswith("#"):
            values[key.strip()] = value.strip().strip('"').strip("'")
    return values


def family(os_id: str, id_like: str) -> str:
    """First match wins: the distro's own ID, then ID_LIKE in order."""
    for word in [os_id] + id_like.split():
        for name, members in FAMILIES.items():
            if word in members or (name == "suse" and word.startswith("opensuse")):
                return name
    return "linux"


def _read_os_release() -> Dict[str, str]:
    for path in ("/etc/os-release", "/usr/lib/os-release"):
        try:
            with open(path, encoding="utf-8") as handle:
                return parse_os_release(handle.read())
        except OSError:
            continue
    return {}


def _can_sudo(no_sudo: bool) -> bool:
    if no_sudo or shutil.which("sudo") is None:
        return False
    try:
        return subprocess.run(["sudo", "-n", "true"], capture_output=True, timeout=5).returncode == 0
    except (OSError, subprocess.SubprocessError):
        return False


def _is_wsl() -> bool:
    try:
        with open("/proc/version", encoding="utf-8") as handle:
            return "microsoft" in handle.read().lower()
    except OSError:
        return False


def detect(no_sudo: bool = False) -> Host:
    system = platform.system()
    is_root = hasattr(os, "geteuid") and os.geteuid() == 0
    if system == "Darwin":
        version = platform.mac_ver()[0] or platform.release()
        return Host("macos", "macOS " + version, platform.machine(), is_root, False, False)
    if system != "Linux":
        return Host("unknown", system or "unknown", platform.machine(), is_root, False, False)
    release = _read_os_release()
    name = family(release.get("ID", ""), release.get("ID_LIKE", ""))
    pretty = release.get("PRETTY_NAME") or release.get("NAME") or "Linux"
    can_sudo = not is_root and _can_sudo(no_sudo)
    return Host(name, pretty, platform.machine(), is_root and not no_sudo, can_sudo, _is_wsl())
