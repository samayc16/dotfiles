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

# Stands in for `claude` in the Claude split: logs keys like KEYLOG, and connects to
# claudecode.nvim's IDE websocket the way the real CLI does (port from the terminal's env,
# token from the lock file), appending each message nvim sends it to <log>.ide as a line.
# Each line a test appends to <log>.send goes to nvim, as Claude's requests do.
FAKE_CLAUDE = """\
import base64, json, os, socket, struct, sys, threading, time, tty
log = sys.argv[1]
port = os.environ["CLAUDE_CODE_SSE_PORT"]
with open(os.path.join(os.environ["CLAUDE_CONFIG_DIR"], "ide", port + ".lock")) as f:
    token = json.load(f)["authToken"]
sock = socket.create_connection(("127.0.0.1", int(port)))
sock.sendall((
    "GET / HTTP/1.1\\r\\nHost: 127.0.0.1:%s\\r\\nUpgrade: websocket\\r\\nConnection: Upgrade\\r\\n"
    "Sec-WebSocket-Key: %s\\r\\nSec-WebSocket-Version: 13\\r\\nx-claude-code-ide-authorization: %s\\r\\n\\r\\n"
    % (port, base64.b64encode(os.urandom(16)).decode(), token)).encode())
reply = b""
while b"\\r\\n\\r\\n" not in reply:
    reply += sock.recv(4096)
assert reply.startswith(b"HTTP/1.1 101"), reply

def recv_exact(n):
    data = b""
    while len(data) < n:
        chunk = sock.recv(n - len(data))
        if not chunk:
            raise EOFError
        data += chunk
    return data

sending = threading.Lock()

def send(opcode, payload):  # clients must mask their frames
    mask, n = os.urandom(4), len(payload)
    head = bytes([0x80 | opcode]) + (bytes([0x80 | n]) if n < 126 else bytes([0xFE]) + struct.pack(">H", n))
    with sending:
        sock.sendall(head + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(payload)))

def requests():
    sent = 0
    while True:
        time.sleep(0.05)
        try:
            with open(log + ".send") as f:
                lines = f.read().splitlines()
        except OSError:
            continue
        for line in lines[sent:]:
            send(1, line.encode())
        sent = len(lines)

def websocket():
    with open(log + ".ide", "a") as out:
        while True:
            b0, b1 = recv_exact(2)
            n = b1 & 0x7F
            n = struct.unpack(">H", recv_exact(2))[0] if n == 126 else struct.unpack(">Q", recv_exact(8))[0] if n == 127 else n
            mask = recv_exact(4) if b1 & 0x80 else b"\\0\\0\\0\\0"
            payload = bytes(b ^ mask[i % 4] for i, b in enumerate(recv_exact(n)))
            opcode = b0 & 0x0F
            if opcode == 1:
                out.write(payload.decode() + "\\n")
                out.flush()
            elif opcode == 9:
                send(0xA, payload)
            elif opcode == 8:
                return

threading.Thread(target=websocket, daemon=True).start()
threading.Thread(target=requests, daemon=True).start()
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
        (tmp / "fake_claude.py").write_text(FAKE_CLAUDE)

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

    def keylogger(self, name, script="keylog.py"):
        log = self.tmp / name
        self.logs.append(log)
        cmd = " ".join(shlex.quote(p) for p in (sys.executable, str(self.tmp / script), str(log)))
        return log, cmd

    def open_claude(self, name="claude", connect=False):
        """The split <leader>ac opens, running a key logger (connect=True: FAKE_CLAUDE,
        connected to the IDE server like the real CLI) in place of `claude`. Returns the
        log and the split's window, in terminal mode."""
        log, cmd = self.keylogger(name, "fake_claude.py" if connect else "keylog.py")
        self.nvim.lua("require('claudecode.terminal').setup({ split_side = 'right', split_width_percentage = 0.4 }, %s) return true" % lua_str(cmd))
        self.type(LEADER + b"ac")
        self.wait_ready(log)
        win = self.wait_state("the Claude split in terminal mode", buftype="terminal", mode="t")["win"]
        if connect:
            wait_for("Claude to connect to nvim", lambda: self.nvim.lua("return require('claudecode').is_claude_connected()"))
        return log, win

    @staticmethod
    def ide_log(log):
        path = Path(str(log) + ".ide")
        return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

    def ide_messages(self, log, method):
        return [m["params"] for m in self.ide_log(log) if m.get("method") == method]

    def ide_reply(self, log, request_id):
        return next((m for m in self.ide_log(log) if m.get("id") == request_id), None)

    @staticmethod
    def claude_calls(log, request_id, tool, arguments):
        """Fake Claude calls an MCP tool in nvim, as `claude` does to propose an edit."""
        call = {"jsonrpc": "2.0", "id": request_id, "method": "tools/call", "params": {"name": tool, "arguments": arguments}}
        with open(str(log) + ".send", "a") as f:
            f.write(json.dumps(call) + "\n")

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
    log, claude = s.open_claude()
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
def claude_send_selection_focuses_claude(s):
    """With Claude open and connected, <leader>as on a selection sends those lines and
    moves to Claude's prompt, so the question can be typed straight away."""
    code = s.tmp / "code.py"
    code.write_text("one\ntwo\nthree\nfour\n")
    s.start_nvim(code)
    log, claude = s.open_claude(connect=True)
    s.type(CTRL["h"])
    s.wait_state("back in the file", buftype="", mode="n")
    s.type(b"jVj")
    s.wait_state("lines 2-3 selected", mode="V")
    s.type(LEADER + b"as")
    s.wait_state("Claude's prompt, typing", win=claude, mode="t")
    sent = wait_for("Claude to get the selection", lambda: s.ide_messages(log, "at_mentioned"))
    if len(sent) != 1 or not sent[0]["filePath"].endswith("code.py") or (sent[0]["lineStart"], sent[0]["lineEnd"]) != (1, 2):
        raise Failure("Claude got %r, wanted one mention of code.py lines 1-2 (0-based)" % sent)
    s.assert_nothing_typed(log)
    s.type(b"why?")
    wait_for("Claude to get the question", lambda: s.received(log) == b"why?")
    s.type(CTRL["h"])
    s.wait_state("the file again, out of visual mode", buftype="", mode="n")
    s.type(LEADER + b"ab")  # the whole buffer, same behaviour
    s.wait_state("Claude's prompt after <leader>ab", win=claude, mode="t")
    wait_for("Claude to get the buffer", lambda: len(s.ide_messages(log, "at_mentioned")) == 2)


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


# -- autosave ----------------------------------------------------------------------

AUTOSAVE = 0.3  # nvim/lua/config/autosave.lua's DELAY_MS


def in_project(s, name, text):
    """A file in a git repo. Tests run in a temp dir, and autosave skips temp files
    outside a repo ($EDITOR files: zsh's Ctrl-X Ctrl-E, crontab -e)."""
    proj = s.tmp / "proj"
    if not (proj / ".git").exists():
        proj.mkdir(parents=True, exist_ok=True)
        run(["git", "init", "-q", str(proj)], s.tmux.env)
    path = proj / name
    path.write_text(text)
    return path


def buffer_modified(s):
    return s.nvim.lua("return vim.bo.modified")


def assert_not_saved(s, path, text, what):
    time.sleep(AUTOSAVE + SETTLE)
    if path.read_text() != text:
        raise Failure("%s was saved: the file has %r" % (what, path.read_text()))
    if not buffer_modified(s):
        raise Failure("%s: the buffer lost its unsaved change" % what)


@test
def autosave_after_changes(s):
    """Leaving insert mode, dw and u each save the file; typing doesn't. <leader>ta
    turns it off, and back on (saving what's pending)."""
    f = in_project(s, "notes.txt", "one two\n")
    s.start_nvim(f)
    s.type(b"Ahi")
    wait_for("the typed text", lambda: s.nvim.lua("return vim.api.nvim_get_current_line()") == "one twohi")
    assert_not_saved(s, f, "one two\n", "a half-typed line")
    s.type(ESC)
    wait_for("leaving insert mode to save", lambda: f.read_text() == "one twohi\n")
    s.type(b"0dw")
    wait_for("dw to save", lambda: f.read_text() == "twohi\n")
    s.type(b"u")
    wait_for("u to save", lambda: f.read_text() == "one twohi\n" and not buffer_modified(s))
    s.type(LEADER + b"ta")
    wait_for("<leader>ta to turn autosave off", lambda: s.nvim.lua("return vim.g.autosave") is False)
    s.type(b"x")
    assert_not_saved(s, f, "one twohi\n", "a change with autosave off")
    s.type(LEADER + b"ta")
    wait_for("<leader>ta back on to save the pending change", lambda: f.read_text() == "ne twohi\n")
    # An LSP rename edits this file and one that isn't open, through the same function.
    other = in_project(s, "other.txt", "twohi()\n")
    s.nvim.lua(
        "local function edit(path, last) return { [vim.uri_from_fname(path)] = { { newText = 'renamed', "
        "range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = last } } } } } end "
        "vim.lsp.util.apply_workspace_edit({ changes = vim.tbl_extend('error', edit(%s, 2), edit(%s, 5)) }, 'utf-8') return true"
        % (lua_str(str(f)), lua_str(str(other)))
    )
    wait_for("both files of the rename to save", lambda: (f.read_text(), other.read_text()) == ("renamed twohi\n", "renamed()\n"))


@test
def autosave_skips_format_on_save(s):
    """Autosaves don't run the formatter: text would jump while editing, and `u` would
    be redone by it. :w still formats."""
    f = in_project(s, "notes.txt", "one\n")
    s.start_nvim(f)
    # A formatter for plain text that upper-cases, so format-on-save applies to this file.
    s.nvim.lua("local c = require('conform') c.formatters.shout = { command = 'tr', args = { 'a-z', 'A-Z' } } c.formatters_by_ft.text = { 'shout' } return true")
    s.type(b"otwo" + ESC)
    wait_for("the autosave, unformatted", lambda: f.read_text() == "one\ntwo\n")
    s.type(b"u")
    wait_for("u to autosave, unformatted", lambda: f.read_text() == "one\n")
    s.type(b":w\r")
    wait_for(":w to format", lambda: f.read_text() == "ONE\n")


@test
def autosave_leaves_alone(s):
    """Never autosaved: a temp file outside a repo, a commit message, oil (a write
    deletes files), and a file changed on disk since nvim read it (you're told)."""
    temp = s.tmp / "zshAb12"
    temp.write_text("echo hi\n")
    keep = in_project(s, "keep.txt", "keep\n")
    hunk = keep.parent / ".git" / "ADD_EDIT.patch"  # git add -p's hunk editor
    hunk.write_text("+line\n")
    commit = in_project(s, "COMMIT_EDITMSG", "subject\n")  # a commit message by filetype alone
    s.start_nvim(temp)
    s.type(b"x")
    assert_not_saved(s, temp, "echo hi\n", "a temp file outside a repo")
    for path, filetype, text in ((hunk, "diff", "+line\n"), (commit, "gitcommit", "subject\n")):
        s.nvim.lua("vim.cmd.edit(%s) return true" % lua_str(str(path)))
        s.wait_state(path.name, filetype=filetype)
        s.type(b"x")
        assert_not_saved(s, path, text, path.name)
    s.nvim.lua("vim.cmd.edit(%s) return true" % lua_str(str(keep.parent)))  # oil
    s.wait_state("oil", filetype="oil")
    listing = lambda: "\n".join(s.nvim.lua("return vim.api.nvim_buf_get_lines(0, 0, -1, false)"))  # noqa: E731
    wait_for("oil to list keep.txt", lambda: "keep.txt" in listing())  # it reads the directory async
    s.type(b"/keep\rdd")
    wait_for("dd to delete keep.txt's line", lambda: "keep.txt" not in listing())
    time.sleep(AUTOSAVE + SETTLE)
    # A write would delete keep.txt, or first ask in a floating confirm window.
    floats = s.nvim.lua("return #vim.tbl_filter(function(w) return vim.api.nvim_win_get_config(w).relative ~= '' end, vim.api.nvim_list_wins())")
    if not keep.exists() or floats:
        raise Failure("autosave wrote the oil buffer (keep.txt exists: %s, oil's confirm open: %s)" % (keep.exists(), bool(floats)))
    if not buffer_modified(s):
        raise Failure("the oil buffer lost its pending delete")
    # Someone else (Claude in another pane, git checkout) rewrites the file nvim has open.
    s.nvim.lua("vim.cmd.edit(%s) return true" % lua_str(str(keep)))
    s.wait_state("keep.txt", filetype="text")
    keep.write_text("their version\n")
    s.type(b"x")
    assert_not_saved(s, keep, "their version\n", "a file changed on disk")
    told = s.nvim.lua(
        "local said = vim.api.nvim_exec2('messages', { output = true }).output "
        "local ok, history = pcall(function() return Snacks.notifier.get_history() end) "
        "for _, n in ipairs(ok and history or {}) do said = said .. tostring(n.msg) end "
        "return said:find('changed on disk', 1, true) ~= nil"
    )
    if not told:
        raise Failure("no message that keep.txt changed on disk")


@test
def autosave_never_accepts_claude_diff(s):
    """Claude's proposed edit opens as a diff, and writing the proposal accepts it. Editing
    the proposal and leaving it must not autosave (accept) it; only :w does."""
    code = in_project(s, "code.txt", "old\n")
    s.start_nvim(code)
    log, _ = s.open_claude(connect=True)
    s.claude_calls(log, 1, "openDiff", {
        "old_file_path": str(code), "new_file_path": str(code), "new_file_contents": "new\n",
        "tab_name": "✻ [Claude Code] code.txt ⧉",  # what claude sends
    })
    proposal = wait_for("the proposed diff", lambda: s.nvim.lua(
        "for _, w in ipairs(vim.api.nvim_list_wins()) do "
        "if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)):find('(proposed)', 1, true) then return w end end"))
    s.nvim.lua("vim.api.nvim_set_current_win(%d) vim.cmd.stopinsert() return true" % proposal)
    s.wait_state("in the proposal", win=proposal, mode="n")
    s.type(b"A, edited" + ESC)
    s.type(CTRL["h"])  # leave it: BufLeave
    s.wait_state("out of the proposal", buftype="")
    time.sleep(AUTOSAVE + SETTLE)
    if s.ide_reply(log, 1) or code.read_text() != "old\n":
        raise Failure("autosave accepted Claude's diff: Claude got %r, code.txt has %r" % (s.ide_reply(log, 1), code.read_text()))
    s.nvim.lua("vim.api.nvim_set_current_win(%d) return true" % proposal)
    s.type(b":w\r")
    reply = wait_for("Claude to hear :w accept the diff", lambda: s.ide_reply(log, 1))
    if "FILE_SAVED" not in json.dumps(reply):
        raise Failure(":w didn't accept the diff: Claude got %r" % reply)


@test
def autosave_on_leaving_the_pane(s):
    """Mid-insert, moving to another tmux pane (where `learn check` or Claude runs)
    saves at once."""
    f = in_project(s, "a.txt", "a\n")
    nvim_pane = s.start_nvim(f)
    log, cmd = s.keylogger("pane")
    right = s.tmux.split(cmd)
    s.wait_ready(log)
    s.tmux.select(nvim_pane)
    s.type(b"Ab")
    wait_for("the typed text", lambda: s.nvim.lua("return vim.api.nvim_get_current_line()") == "ab")
    s.tmux.select(right)
    wait_for("leaving the pane to save", lambda: f.read_text() == "ab\n", timeout=AUTOSAVE * 2)


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
