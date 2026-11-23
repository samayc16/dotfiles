"""The install steps and how a profile + flags select them.

Each step is a small bash script in install.d/ (shell is the right tool for package
managers, curl-installers and git). Steps are idempotent and fail-soft: a failing step
is reported in the summary and the rest still run. A step exits 3 to mean "skipped".
"""

from __future__ import annotations

import shutil
from dataclasses import dataclass, field
from typing import Callable, FrozenSet, List, Tuple, Union

from .host import Host

PROFILES = ("cli", "dev", "full")
PROFILE_HELP = {
    "cli": "shell, tmux, Neovim + plugins, CLI tools, font, Claude Code",
    "dev": "cli + language servers/formatters/debuggers, parsers, HDL toolchain, smoke test",
    "full": "dev + Swift (Linux), Haskell, games, learning tracks — everything (default)",
}

ScriptChoice = Union[str, Callable[[Host], str]]
Flag = Union[bool, Callable[[Host], bool]]


@dataclass(frozen=True)
class Step:
    name: str
    summary: str
    script: ScriptChoice
    profile: str = "cli"  # lowest profile that includes this step
    platforms: FrozenSet[str] = field(default_factory=lambda: frozenset({"macos", "linux"}))
    interactive: Flag = False  # may prompt (sudo password, Homebrew installer)

    def script_for(self, host: Host) -> str:
        return self.script(host) if callable(self.script) else self.script

    def runs_on(self, host: Host) -> bool:
        return ("macos" if host.is_mac else "linux") in self.platforms

    def is_interactive(self, host: Host) -> bool:
        return self.interactive(host) if callable(self.interactive) else self.interactive


LINUX = frozenset({"linux"})

STEPS: Tuple[Step, ...] = (
    Step(
        "packages",
        "system packages (Homebrew on macOS, distro packages on Linux)",
        lambda h: "brew.sh" if h.is_mac else "system.sh",
        interactive=lambda h: h.is_mac and shutil.which("brew") is None,
    ),
    Step("fonts", "Meslo Nerd Font", "fonts.sh"),
    Step("links", "symlink configs into place", "links.sh"),
    Step("mise", "user-local CLI tools: neovim, ripgrep, fzf, … (no root)", "mise.sh", platforms=LINUX),
    Step("zsh", "zsh, prompt + plugins, login shell", "zsh.sh", interactive=True),
    Step("nvim", "Neovim plugins (+ LSPs, debuggers, parsers on dev/full)", "nvim.sh"),
    Step("claude", "Claude Code CLI", "claude.sh"),  # after nvim: reuses its lua-language-server
    Step("hdl", "Verilator, Icarus Verilog, Surfer", "hdl.sh", profile="dev", platforms=LINUX),
    Step("rust", "Rust via rustup: cargo, rust-analyzer, clippy, rustfmt", "rust.sh", profile="dev"),
    Step("swift", "Swift toolchain via swiftly", "swift.sh", profile="full", platforms=LINUX),
    Step("haskell", "GHC, cabal, haskell-language-server", "haskell.sh", profile="full"),
    Step("games", "offline games + trainers", "games.sh", profile="full"),
    Step("learn", "learning tracks + example projects (~/learn)", "learn.sh", profile="full"),
    Step("smoke", "per-language smoke test in headless Neovim", "smoke.sh", profile="dev"),
)


@dataclass(frozen=True)
class Selection:
    profile: str = "full"
    only: FrozenSet[str] = frozenset()
    skip: FrozenSet[str] = frozenset()
    extra: FrozenSet[str] = frozenset()  # --with


def profile_includes(profile: str, step_profile: str) -> bool:
    return PROFILES.index(profile) >= PROFILES.index(step_profile)


def skip_reason(step: Step, host: Host, selection: Selection) -> str:
    """Empty string when the step should run, otherwise why not."""
    if selection.only:
        return "" if step.name in selection.only else "not in --only"
    if step.name in selection.skip:
        return "--skip"
    if not step.runs_on(host):
        return "not needed on " + ("macOS" if host.is_mac else "Linux")
    if step.name in selection.extra or profile_includes(selection.profile, step.profile):
        return ""
    return "not in profile '%s' (add --with %s)" % (selection.profile, step.name)


def plan(host: Host, selection: Selection, steps: Tuple[Step, ...] = STEPS) -> List[Tuple[Step, str]]:
    return [(step, skip_reason(step, host, selection)) for step in steps]


def unknown_names(names: FrozenSet[str], components: FrozenSet[str]) -> List[str]:
    """Names that are neither steps nor known sub-components (typo guard)."""
    known = {step.name for step in STEPS} | components
    return sorted(name for name in names if name not in known)
