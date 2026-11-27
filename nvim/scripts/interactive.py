#!/usr/bin/env python3
"""Real-use tests: the Neovim config and tmux.conf in this repo, driven by keys.

Keys go into a real tmux client, so they pass through tmux's bindings, then nvim's
mappings, then whatever runs in nvim's terminals, exactly as they do for a person. The
tests then ask nvim (over its socket), tmux, and key-logging programs what each one saw.
That catches what headless tests can't: a mapping that types its own text into Claude's
prompt, a tmux binding that never reaches nvim, a statusline that only errors when drawn.

  python3 nvim/scripts/interactive.py            every test
  python3 nvim/scripts/interactive.py -k nav     the tests whose name contains "nav"

Uses a private tmux server (never yours) and the plugins already installed
(./install.sh --only nvim). nvim's state, cache and Claude lock files go to a temp dir.
Exit 0 only if every test passed. Python 3.6+ (CentOS 7's python3).
"""
import argparse
import fcntl
import json
import os
import pty
import re
import shlex
import shutil
import struct
import subprocess
import sys
import tempfile
import termios
import threading
import time
import traceback
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
COLS, ROWS = 160, 45
TIMEOUT = 20.0
SETTLE = 0.4  # long enough for stray bytes to reach a key logger

CTRL = {c: bytes([ord(c) & 0x1F]) for c in "hjkl"}  # what a terminal sends for Ctrl-<c>
ESC, LEADER = b"\x1b", b" "

# Runs in a terminal and appends every byte it receives to a log: the test's view of
# what a program in that terminal (Claude, a shell) would have been sent.
KEYLOG = """\
import os, sys, tty
log = sys.argv[1]
tty.setraw(0)
open(log + ".ready", "w").close()
with open(log, "ab", buffering=0) as out:
    while True:
        try:
            data = os.read(0, 1024)
        except OSError:
            break
        if not data:
            break
        out.write(data)
"""


class Failure(Exception):
    pass


def lua_str(s):
    return json.dumps(s)  # a JSON string is a valid Lua string literal for these inputs


def wait_for(what, check, timeout=TIMEOUT):
    """Poll `check` until it returns something truthy; fail with the last value seen."""
    deadline = time.monotonic() + timeout
    last = None
    while time.monotonic() < deadline:
        try:
            last = check()
            if last:
                return last
        except Failure:
            raise
        except Exception as e:  # not ready yet (socket not up, pane gone): retry
            last = e
        time.sleep(0.05)
    raise Failure("timed out waiting for %s (last: %r)" % (what, last))


def run(argv, env, timeout=15):
    r = subprocess.run(argv, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, timeout=timeout)
    if r.returncode != 0:
        raise RuntimeError("%s: %s" % (" ".join(argv[:4]), (r.stderr or r.stdout).strip()))
    return r.stdout


class Tmux:
    """A private tmux server with one client attached through a pty. Bytes written to the
    pty are keystrokes, handled by tmux's key tables like a person's typing."""

    def __init__(self, env):
        self.name = "dotfiles-test-%d" % os.getpid()
        self.env = env
        self.client_pid = self.client_fd = None

    def __call__(self, *args):
        return run(["tmux", "-L", self.name, "-f", str(REPO / "tmux.conf")] + list(args), self.env).strip()

    def start(self, command):
        pane = self("new-session", "-d", "-s", "t", "-x", str(COLS), "-y", str(ROWS), "-P", "-F", "#{pane_id}", command)
        self.attach()
        return pane

    def attach(self):
        pid, fd = pty.fork()
        if pid == 0:  # the client, in its own pty sized like a real terminal
            fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", ROWS, COLS, 0, 0))
            os.execvpe("tmux", ["tmux", "-L", self.name, "attach", "-t", "t"], dict(self.env, TERM="xterm-256color"))
        self.client_pid, self.client_fd = pid, fd
        threading.Thread(target=self._drain, daemon=True).start()  # a full pty would block tmux
        wait_for("the tmux client to attach", lambda: self("list-clients", "-F", "#{client_tty}"))

    def _drain(self):
        try:
            while os.read(self.client_fd, 65536):
                pass
        except OSError:
            pass

    def type(self, data):
        os.write(self.client_fd, data)

    def split(self, command):
        return self("split-window", "-h", "-t", "t", "-P", "-F", "#{pane_id}", command)

    def select(self, pane):
        self("select-pane", "-t", pane)

    def active_pane(self):
        return self("display-message", "-p", "-t", "t", "#{pane_id}")

    def screen(self, pane):
        return self("capture-pane", "-p", "-t", pane)

    def stop(self):
        try:
            self("kill-server")
        except Exception:
            pass
        if self.client_pid:
            try:
                os.kill(self.client_pid, 9)
                os.waitpid(self.client_pid, 0)
            except OSError:
                pass


class Nvim:
    """Talks to the nvim under test over its --listen socket, out of band from the keys."""

    def __init__(self, tmp, env, sock):
        self.sock = sock
        self.rpc = tmp / "rpc.lua"
        self.env = env

    def command(self, overrides, files):
        assigns = ["%s=%s" % (k, shlex.quote(v)) for k, v in sorted(overrides.items())]
        return " ".join(["env"] + assigns + ["nvim", "--listen", shlex.quote(self.sock)] + [shlex.quote(str(f)) for f in files])

    def lua(self, code):
        """Run a Lua chunk in the nvim under test; return its JSON-able result."""
        self.rpc.write_text(code)
        expr = (
            "luaeval('(function(src) local ok, v = pcall(assert(loadstring(src))) "
            "return vim.json.encode(ok and { ok = true, v = v } or { ok = false, v = tostring(v) }) end)(_A)', "
            "join(readfile('%s'), \"\\n\"))" % self.rpc
        )
        out = run(["nvim", "--clean", "--headless", "--server", self.sock, "--remote-expr", expr], self.env)
        result = json.loads(out)
        if not result.get("ok"):
            raise Failure("Lua error in the nvim under test: %s" % result.get("v"))
        return result.get("v")

    def state(self):
        return self.lua(
            "local win = vim.api.nvim_get_current_win() local buf = vim.api.nvim_win_get_buf(win) "
            "return { win = win, buftype = vim.bo[buf].buftype, filetype = vim.bo[buf].filetype, "
            "mode = vim.api.nvim_get_mode().mode, float = vim.api.nvim_win_get_config(win).relative ~= '' }"
        )


class Session:
    """One test's world: a tmux server, an nvim in its first pane, key loggers."""

    def __init__(self, tmp, env, nvim_env, sock):
        self.tmp = tmp
        self.tmux = Tmux(env)
        self.nvim = Nvim(tmp, env, sock)
        self.nvim_env = nvim_env
        self.pane = None
        self.logs = []
        (tmp / "keylog.py").write_text(KEYLOG)

    def start_nvim(self, *files, dashboard=False):
        if not files and not dashboard:  # a file, so tests start in an editor window
            files = (self.tmp / "scratch.txt",)
        self.pane = self.tmux.start(self.nvim.command(self.nvim_env, files))
        # VeryLazy plugins (claudecode, bufferline, which-key) load after the UI is up.
        wait_for("nvim to finish starting", lambda: self.nvim.lua("return package.loaded['claudecode'] ~= nil"))
        lazy_ui = self.nvim.lua(
            "for _, w in ipairs(vim.api.nvim_list_wins()) do "
            "if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'lazy' then return true end end return false"
        )
        if lazy_ui:
            missing = self.nvim.lua(
                "local out = {} for _, p in ipairs(require('lazy.core.config').spec.plugins) do "
                "if not p._.installed then table.insert(out, p.name) end end return out"
            )
            raise Failure("lazy.nvim's window is open (missing plugins: %s): run ./install.sh --only nvim" % (missing or "none"))
        return self.pane

    def keylogger(self, name):
        log = self.tmp / name
        self.logs.append(log)
        cmd = " ".join(shlex.quote(p) for p in (sys.executable, str(self.tmp / "keylog.py"), str(log)))
        return log, cmd

    def wait_ready(self, log):
        wait_for("%s to start" % log.name, lambda: Path(str(log) + ".ready").exists())

    @staticmethod
    def received(log):
        return log.read_bytes() if log.exists() else b""

    def assert_nothing_typed(self, *logs):
        time.sleep(SETTLE)
        for log in logs:
            got = self.received(log)
            if got:
                raise Failure("keys leaked into %s: %r" % (log.name, got))

    def wait_state(self, what, **want):
        def matches():
            s = self.nvim.state()
            return s if all(s.get(k) == v for k, v in want.items()) else None

        try:
            return wait_for(what, matches)
        except Failure:
            raise Failure("%s: wanted %r, nvim is at %r" % (what, want, self.nvim.state()))

    def type(self, data):
        self.tmux.type(data)

    def stop(self):
        try:  # quit cleanly so plugins tidy up (claudecode removes its lock file)
            run(["nvim", "--clean", "--headless", "--server", self.nvim.sock, "--remote-send", "<C-\\><C-n>:qa!<CR>"], self.tmux.env, timeout=5)
        except Exception:
            pass
        self.tmux.stop()


TESTS = []


def test(fn):
    TESTS.append(fn)
    return fn


# -- Ctrl-h/j/k/l ------------------------------------------------------------------


@test
def nav_between_splits(s):
    """Ctrl-h/l move between nvim splits."""
    s.start_nvim()
    right = s.nvim.lua("vim.cmd.vsplit() return vim.api.nvim_get_current_win()")  # splitright
    s.type(CTRL["h"])
    left = wait_for("Ctrl-h to move left", lambda: s.nvim.state()["win"] != right and s.nvim.state()["win"])
    s.type(CTRL["l"])
    s.wait_state("Ctrl-l to move back right", win=right)
    s.type(CTRL["h"])
    s.wait_state("Ctrl-h again", win=left)


@test
def nav_insert_ctrl_k_goes_up(s):
    """Ctrl-k in insert mode leaves insert mode and moves up (it's the digraph key otherwise)."""
    s.start_nvim()
    top = s.nvim.lua("local top = vim.api.nvim_get_current_win() vim.cmd.split() return top")  # splitbelow
    s.type(b"i")
    s.wait_state("insert mode", mode="i")
    s.type(CTRL["k"])
    s.wait_state("Ctrl-k to move up in normal mode", win=top, mode="n")


@test
def nav_terminal_split_types_nothing(s):
    """Ctrl-h/l between a terminal split and the editor type nothing into the terminal,
    and coming back resumes typing into it."""
    s.start_nvim()
    log, cmd = s.keylogger("terminal")
    s.nvim.lua("vim.cmd.vsplit() vim.cmd.terminal(%s) vim.cmd.startinsert() return true" % lua_str(cmd))
    s.wait_ready(log)
    term = s.wait_state("terminal mode", mode="t")["win"]
    s.type(CTRL["h"])
    s.wait_state("Ctrl-h to leave the terminal", buftype="", mode="n")
    s.assert_nothing_typed(log)
    s.type(CTRL["l"])
    s.wait_state("Ctrl-l back into terminal mode", win=term, mode="t")
    s.type(b"x")
    wait_for("the terminal to get the next key", lambda: s.received(log) == b"x")


@test
def nav_claude_split_types_nothing(s):
    """The Claude split (claudecode.nvim, <leader>ac): Ctrl-h/j/k/l must never reach
    Claude's prompt. The plugin's own terminal maps typed "TmuxNavigateLeft" into it."""
    s.start_nvim()
    s.type(CTRL["l"])  # first use loads vim-tmux-navigator: its own terminal maps appeared then
    log, cmd = s.keylogger("claude")
    # The same split <leader>ac opens, running the key logger instead of `claude`.
    s.nvim.lua("require('claudecode.terminal').setup({ split_side = 'right', split_width_percentage = 0.4 }, %s) return true" % lua_str(cmd))
    s.type(LEADER + b"ac")
    s.wait_ready(log)
    claude = s.wait_state("the Claude split in terminal mode", buftype="terminal", mode="t")["win"]
    for key in "jk":  # no window above or below: tmux has no pane there either
        s.type(CTRL[key])
    s.type(CTRL["h"])
    s.wait_state("Ctrl-h to the editor", buftype="", mode="n")
    s.assert_nothing_typed(log)
    s.type(CTRL["l"])
    s.wait_state("Ctrl-l back to Claude, typing", win=claude, mode="t")
    s.type(b"hi")
    wait_for("Claude to get the typed text", lambda: s.received(log) == b"hi")


@test
def nav_to_tmux_pane_and_back(s):
    """At nvim's edge Ctrl-l moves to the next tmux pane, from a buffer or a terminal;
    Ctrl-h in a non-vim pane comes back. Neither pane's program sees the keys."""
    nvim_pane = s.start_nvim()
    pane_log, pane_cmd = s.keylogger("pane")
    right = s.tmux.split(pane_cmd)
    s.wait_ready(pane_log)
    s.tmux.select(nvim_pane)

    s.type(CTRL["l"])
    wait_for("Ctrl-l to reach the right tmux pane", lambda: s.tmux.active_pane() == right)
    s.type(CTRL["h"])
    wait_for("Ctrl-h back to nvim's pane", lambda: s.tmux.active_pane() == nvim_pane)

    term_log, term_cmd = s.keylogger("terminal")
    s.nvim.lua("vim.cmd.terminal(%s) vim.cmd.startinsert() return true" % lua_str(term_cmd))
    s.wait_ready(term_log)
    s.wait_state("terminal mode", mode="t")
    s.type(CTRL["l"])
    wait_for("Ctrl-l from a terminal to the right tmux pane", lambda: s.tmux.active_pane() == right)
    s.assert_nothing_typed(pane_log, term_log)


@test
def nav_float_terminal_keeps_keys(s):
    """A floating terminal (<C-/>, lazygit) has no neighbours, so its program gets
    Ctrl-h/j/k/l: shells and pickers use them."""
    s.start_nvim()
    log, cmd = s.keylogger("float")
    s.nvim.lua("Snacks.terminal.open(%s, { win = { position = 'float' } }) return true" % lua_str(cmd))
    s.wait_ready(log)
    s.wait_state("a floating terminal in terminal mode", mode="t", float=True)
    s.type(CTRL["j"] + CTRL["k"])
    wait_for("the float's program to get Ctrl-j Ctrl-k", lambda: s.received(log) == b"\n\x0b")


# -- editing -----------------------------------------------------------------------


@test
def alt_backspace_deletes_word(s):
    """Alt-Backspace deletes the word before the cursor, in insert mode and on the : line."""
    s.start_nvim()
    s.type(b"ihello big world")
    wait_for("the typed text", lambda: s.nvim.lua("return vim.api.nvim_get_current_line()") == "hello big world")
    s.type(ESC + b"\x7f")  # what a terminal sends for Alt-Backspace
    wait_for("Alt-Backspace in insert mode", lambda: s.nvim.lua("return vim.api.nvim_get_current_line()") == "hello big ")
    s.wait_state("still in insert mode", mode="i")
    s.type(ESC)
    time.sleep(SETTLE)  # past tmux's escape-time, so the next key isn't read as Alt-<key>
    s.type(b":let g:typed = 'one two")
    s.type(ESC + b"\x7f" + b"three'\r")
    wait_for("Alt-Backspace on the : line", lambda: s.nvim.lua("return vim.g.typed") == "one three")


@test
def readline_line_ends(s):
    """Ctrl-A / Ctrl-E go to the start / end of the line in insert mode and on the : line.
    Ctrl-A is tmux's prefix, so it's typed twice, as a person does."""
    s.start_nvim()
    line = lambda: s.nvim.lua("return vim.api.nvim_get_current_line()")  # noqa: E731
    C_A, C_E = b"\x01\x01", b"\x05"
    s.type(b"i    indented text")
    wait_for("the typed text", lambda: line() == "    indented text")
    s.type(C_A + b"X")
    wait_for("Ctrl-A to the first non-blank", lambda: line() == "    Xindented text")
    s.type(C_E + b"Y")
    wait_for("Ctrl-E to the end", lambda: line() == "    Xindented textY")
    s.type(C_A + C_A + b"Z")
    wait_for("Ctrl-A again to column 0", lambda: line() == "Z    Xindented textY")
    s.wait_state("still in insert mode", mode="i")
    # With the completion menu open, Ctrl-E closes it and leaves the cursor alone.
    s.type(C_E + b"\rindent")
    menu = lambda: s.nvim.lua("return require('blink.cmp').is_menu_visible()")  # noqa: E731
    wait_for("the completion menu", menu)
    s.type(C_E)
    wait_for("Ctrl-E to close the menu", lambda: not menu())
    s.wait_state("the cursor still after the typed word", mode="i")
    if s.nvim.lua("return vim.api.nvim_get_current_line()") != "indent":
        raise Failure("Ctrl-E with the menu open changed the line")
    s.type(ESC)
    time.sleep(SETTLE)
    s.type(b":ab" + C_A + b"let g:typed = '" + C_E + b"'\r")
    wait_for("Ctrl-A / Ctrl-E on the : line", lambda: s.nvim.lua("return vim.g.typed") == "ab")


# -- what's drawn --------------------------------------------------------------------


def statusline(s):
    """The global statusline: the pane's second-to-last row (the last is the cmdline)."""
    height = int(s.tmux("display-message", "-p", "-t", s.pane, "#{pane_height}"))  # tmux's bar takes a row
    rows = s.tmux.screen(s.pane).split("\n")
    rows += [""] * (height - len(rows))  # capture-pane drops trailing blank rows
    return rows[height - 2]


@test
def statusline_shows_mode_file_and_exercise(s):
    """The statusline draws the mode, the file and, in a learn workspace, the exercise."""
    ex = s.tmp / "learn" / "haskell-koans" / "03-higher-order"
    ex.mkdir(parents=True)
    (ex / ".learn.json").write_text(json.dumps({"track": "haskell-koans", "slug": "03-higher-order"}))
    (ex / "Koan.hs").write_text("module Koan where\n")
    s.start_nvim(ex / "Koan.hs")

    def shows(*words):
        return lambda: all(w in statusline(s) for w in words) and statusline(s)

    wait_for("NORMAL, the file and the exercise", shows("NORMAL", "Koan.hs", "03-higher-order"))
    s.type(b"i")
    wait_for("INSERT", shows("INSERT"))
    s.type(ESC)
    s.nvim.lua("vim.cmd.terminal() vim.cmd.startinsert() return true")
    wait_for("TERMINAL", shows("TERMINAL"))


@test
def dashboard_on_bare_nvim(s):
    """`nvim` with no file opens the dashboard; its keys work, and opening a file leaves it."""
    s.start_nvim(dashboard=True)
    wait_for("the dashboard", lambda: "Restore session" in s.tmux.screen(s.pane) and s.nvim.state()["filetype"] == "snacks_dashboard")
    s.type(b"n")  # New file
    s.wait_state("an empty buffer in insert mode", filetype="", mode="i")


@test
def no_errors_opening_files(s):
    """Startup and opening each language's file leave no errors behind."""
    samples = {
        "main.py": "print('hi')\n",
        "main.c": "int main(void) { return 0; }\n",
        "main.cpp": "int main() { return 0; }\n",
        "init.lua": "print('hi')\n",
        "notes.md": "# Notes\n",
        "top.sv": "module top; endmodule\n",
        "Main.hs": "main = pure ()\n",
        "run.sh": "#!/bin/sh\necho hi\n",
    }
    for name, text in samples.items():
        (s.tmp / name).write_text(text)
    s.start_nvim(s.tmp / "main.py")
    for name in samples:
        s.nvim.lua("vim.cmd.edit(%s) return true" % lua_str(str(s.tmp / name)))
        time.sleep(0.3)  # let FileType plugins, LSP attach and the statusline run
    s.type(LEADER + b"ll")  # which-key + :Learn's picker, then back out
    time.sleep(0.5)
    s.type(ESC + ESC)
    time.sleep(SETTLE)
    errors = s.nvim.lua(
        "local out = {} "
        "for line in vim.api.nvim_exec2('messages', { output = true }).output:gmatch('[^\\n]+') do "
        "  if line:match('E%d+:') or line:match('[Ee]rror') then table.insert(out, line) end end "
        "local ok, notifier = pcall(function() return Snacks.notifier.get_history() end) "
        "for _, n in ipairs(ok and notifier or {}) do "
        "  if n.level == 'error' then table.insert(out, 'notify: ' .. tostring(n.msg)) end end "
        "return out"
    )
    if errors:
        raise Failure("errors:\n  " + "\n  ".join(errors))


# -- runner --------------------------------------------------------------------------


def config_home(tmp):
    """XDG_CONFIG_HOME whose nvim/ is this repo's, like install.d/lib.sh's use_repo_nvim_config."""
    real = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    if (real / "nvim").resolve() == (REPO / "nvim").resolve():
        return str(real)
    shadow = tmp / "config"
    shadow.mkdir()
    if real.is_dir():
        for entry in real.iterdir():
            if entry.name != "nvim":
                (shadow / entry.name).symlink_to(entry)
    (shadow / "nvim").symlink_to(REPO / "nvim")
    return str(shadow)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("-k", dest="pattern", default="", help="run only tests whose name contains this")
    args = parser.parse_args()

    for tool in ("tmux", "nvim"):
        if not shutil.which(tool):
            print("skip: %s not installed" % tool)
            return 0
    chosen = [t for t in TESTS if args.pattern in t.__name__]
    if not chosen:
        print("no test matches %r" % args.pattern)
        return 1

    root = Path(tempfile.mkdtemp(prefix="nvim-interactive-"))
    sockets = Path(tempfile.mkdtemp(prefix="nvt", dir="/tmp"))  # macOS caps socket paths at 104 bytes
    env = {k: v for k, v in os.environ.items() if k not in ("TMUX", "TMUX_PANE", "NVIM", "NVIM_LISTEN_ADDRESS")}
    nvim_env = {
        "XDG_CONFIG_HOME": config_home(root),
        "XDG_STATE_HOME": str(root / "state"),
        "XDG_CACHE_HOME": str(root / "cache"),
        "CLAUDE_CONFIG_DIR": str(root / "claude"),  # claudecode's IDE lock files
    }
    if os.environ.get("XDG_DATA_HOME"):
        nvim_env["XDG_DATA_HOME"] = os.environ["XDG_DATA_HOME"]

    failed = 0
    try:
        for i, fn in enumerate(chosen):
            tmp = root / fn.__name__
            tmp.mkdir()
            s = Session(tmp, env, nvim_env, str(sockets / ("%d.sock" % i)))
            start = time.monotonic()
            try:
                fn(s)
                print("PASS %-40s %.1fs" % (fn.__name__, time.monotonic() - start))
            except Exception as e:
                failed += 1
                print("FAIL %-40s %s" % (fn.__name__, (fn.__doc__ or "").strip().split("\n")[0]))
                detail = str(e) if isinstance(e, Failure) else traceback.format_exc()
                print("     " + detail.replace("\n", "\n     "))
                for log in s.logs:
                    print("     %s received %r" % (log.name, s.received(log)))
                if s.pane:
                    try:
                        print("     screen:\n       " + s.tmux.screen(s.pane).rstrip().replace("\n", "\n       "))
                    except Exception:
                        pass
            finally:
                s.stop()
    finally:
        shutil.rmtree(str(root), ignore_errors=True)
        shutil.rmtree(str(sockets), ignore_errors=True)
    print("%d/%d passed" % (len(chosen) - failed, len(chosen)))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
