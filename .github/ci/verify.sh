#!/bin/sh
# Check a finished install (CI). Run as the user who installed, with:
#   PINS=<the pins.txt it installed with>   LEARN=1 when the learn step ran
#   RELEASE=1 when it was a release install (bin/dotfiles install --from <tarball>)
set -eu
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/bin:$PATH"
fail() { echo "verify: $*" >&2; exit 1; }
pin_of() { awk -v n="$1" '$1 == n { print $4 }' "$PINS"; }

echo "nvim: $(nvim --version | head -n1)"
v=$(nvim --version | head -n1 | sed 's/^NVIM v//; s/-.*//')
[ "$(printf '%s\n0.12.0\n' "$v" | sort -V | head -n1)" = 0.12.0 ] || fail "nvim too old: $v"
for t in rg fd fzf bat eza delta lazygit zoxide tree-sitter; do printf '%-12s ' "$t"; "$t" --version 2>&1 | head -n1; done
printf '%-12s ' tmux; tmux -V

# Links, and for a release install: through ~/.local/share/dotfiles/current, so a flip moves them all
for l in .zshrc .tmux.conf .tmux/scripts .gitconfig .config/nvim .config/mise/config.toml .config/clangd/config.yaml bin/dotfiles; do
  [ -L "$HOME/$l" ] && [ -e "$HOME/$l" ] || fail "missing link: ~/$l"
done
if [ "${RELEASE:-0}" = 1 ]; then
  [ "$(readlink "$HOME/.zshrc")" = "$HOME/.local/share/dotfiles/current/zshrc" ] || fail "$HOME/.zshrc → $(readlink "$HOME/.zshrc"), not through current"
  dotfiles status
fi
[ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ] || fail "Claude settings must be a copy, not a link"

if command -v script >/dev/null; then out=$(script -qec "zsh -ic 'echo ZSH_OK; exit'" /dev/null 2>&1)
else out=$(zsh -ic 'echo ZSH_OK' 2>&1 | grep -v "can't change option: zle"); fi
echo "$out" | grep -q ZSH_OK || fail "zsh failed: $out"
if echo "$out" | grep -E -i 'not found|error|no such file'; then fail "zsh startup printed errors"; fi
nvim --headless "+Lazy! restore" +qa

# tmux plugins: each at its pin, and TPM's own first run finds them all (installs nothing)
grep '^tmux/' "$PINS" | while read -r name _ _ rev; do
  dir="$HOME/.tmux/plugins/${name#tmux/}"
  [ "$(git -C "$dir" rev-parse HEAD)" = "$rev" ] || fail "$dir is not at its pin $rev"
done
TERM=xterm-256color tmux new-session -d -s verify
tpm_out=$("$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>&1)
tmux kill-server
echo "$tpm_out"
echo "$tpm_out" | grep -q 'Already installed "tmux-yank"' || fail "TPM didn't see the pre-cloned plugins"
if echo "$tpm_out" | grep -q 'Installing'; then fail "TPM cloned plugins the installer should have"; fi

# plexamp-tui: the pinned release (or the bundled wheel), working without mpv
tamp --version
tamp status
want=$(pin_of plexamp-tui)
[ "$want" = - ] || tamp --version | grep -q "${want#v}" || fail "tamp is not the pinned $want"

# learn: every pinned repo cloned at its commit
if [ "${LEARN:-0}" = 1 ]; then
  n=0 repos=$(mktemp)
  find "$HOME/learn" -maxdepth 5 -name .git -type d -prune >"$repos"
  while read -r git_dir; do
    repo=${git_dir%/.git}
    url=$(git -C "$repo" config remote.origin.url) rev=$(git -C "$repo" rev-parse HEAD)
    awk -v u="$url" -v r="$rev" '$3 == u && $4 == r { f = 1 } END { exit !f }' "$PINS" || fail "$repo ($url) is at $rev, not its pin"
    n=$((n + 1))
  done <"$repos"
  [ "$n" -eq "$(grep -c '^learn/' "$PINS")" ] || fail "expected $(grep -c '^learn/' "$PINS") learn repos, found $n"
  for doc in cppreference/reference/en/index.html sv/verilator/docs/guide swift/swift-book/TSPL.docc haskell/lyah/source_md; do
    [ -e "$HOME/learn/docs/$doc" ] || fail "missing offline doc: $doc"
  done
  echo "learn: $n pinned repos + offline docs"
fi

cd "$(mktemp -d)" # both simulators, end to end
# shellcheck disable=SC2016 # $display is SystemVerilog
printf 'module t; initial begin $display("sim ok"); $finish; end endmodule\n' >t.sv
{ iverilog -g2012 -o t.vvp t.sv && vvp t.vvp | grep -q 'sim ok'; } || fail "iverilog failed"
{ verilator --binary -Wno-fatal t.sv >/dev/null && ./obj_dir/Vt | grep -q 'sim ok'; } || fail "verilator failed"
echo "simulators: verilator $(verilator --version | cut -d' ' -f2), iverilog $(iverilog -V 2>&1 | head -n1 | cut -d' ' -f4)"
echo "verify: all good"
