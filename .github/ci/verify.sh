#!/bin/sh
# Check a finished install (CI, Linux and macOS). Run as the user who installed, with:
#   PINS=<the pins.txt it installed with>   LEARN=1 when the learn step ran
#   RELEASE=1 when it was a release install (bin/dotfiles install --from <tarball>)
#   SIM=0 when no HDL toolchain was installed   NVIM=0 when there is no Neovim (musl)
set -eu
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/bin:$PATH"
[ "$(uname -s)" = Darwin ] && mac=1 || mac=0
nvim_on=${NVIM:-1}
fail() { echo "verify: $*" >&2; exit 1; }
pin_of() { awk -v n="$1" '$1 == n { print $4 }' "$PINS"; }

tools="rg fd fzf bat eza delta lazygit zoxide atuin sesh yazi btop direnv"
if [ "$nvim_on" = 1 ]; then
  echo "nvim: $(nvim --version | head -n1)"
  v=$(nvim --version | head -n1 | sed 's/^NVIM v//; s/-.*//')
  [ "$(printf '%s\n0.12.0\n' "$v" | sort -V | head -n1)" = 0.12.0 ] || fail "nvim too old: $v"
  tools="$tools tree-sitter"
else
  ! command -v nvim >/dev/null || fail "NVIM=0 but nvim is installed"
fi
# the first line of --version with a version number in it (eza and yazi print a banner first)
for t in $tools; do printf '%-12s ' "$t"; "$t" --version 2>&1 | grep -m1 -E '[0-9]+\.[0-9]+' || fail "$t --version shows no version"; done
printf '%-12s ' tmux; tmux -V

# Linux tools are self-contained downloads: static, except where upstream publishes no static
# build (neovim, tree-sitter, node; mise/global.toml says why). zsh-bin's zsh must be static too.
if [ "$mac" = 0 ]; then
  command -v file >/dev/null || fail "verify needs file(1)"
  for t in mise tmux rg fd fzf bat eza delta lazygit zoxide jq gh uv atuin sesh yazi ya btop direnv node nvim tree-sitter zsh; do
    case $t in
      nvim | tree-sitter) [ "$nvim_on" = 1 ] || continue ;;
      zsh) [ -x "$HOME/.local/bin/zsh" ] || continue ;;
      node) # newer Node needs libatomic.so.1, a system library only root can add; the installer says so
        if ! ldconfig -p 2>/dev/null | grep -q libatomic.so.1 && [ ! -e /usr/lib/libatomic.so.1 ] && ! mise which node >/dev/null 2>&1; then
          echo "node         not installed: this box lacks libatomic.so.1 (the installer warned)"
          continue
        fi ;;
    esac
    case $t in mise | zsh) bin=$(command -v "$t") ;; *) bin=$(mise which "$t") ;; esac
    info=$(file -L "$bin")
    case "$info" in
      *interpreter*) interp=$(echo "$info" | sed 's/.*interpreter \([^,]*\).*/\1/')
        case $t in nvim | tree-sitter | node) printf '%-12s dynamic (%s), a documented exception\n' "$t" "$interp" ;;
          *) fail "$t ($bin) is dynamically linked ($interp): pick its static build in mise/global.toml" ;; esac ;;
      *ELF*) printf '%-12s static\n' "$t" ;;
      *) fail "$t ($bin) is not an ELF binary: $info" ;;
    esac
  done
fi

# Links, and for a release install: through ~/.local/share/dotfiles/current, so a flip moves them all
clangd=.config/clangd/config.yaml
[ "$mac" = 1 ] && clangd=Library/Preferences/clangd/config.yaml
for l in .zshrc .tmux.conf .tmux/scripts .gitconfig .atuin/config.toml .config/nvim .config/mise/config.toml "$clangd" bin/dotfiles; do
  [ -L "$HOME/$l" ] && [ -e "$HOME/$l" ] || fail "missing link: ~/$l"
done
if [ "${RELEASE:-0}" = 1 ]; then
  [ "$(readlink "$HOME/.zshrc")" = "$HOME/.local/share/dotfiles/current/zshrc" ] || fail "$HOME/.zshrc → $(readlink "$HOME/.zshrc"), not through current"
  dotfiles status
fi
[ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ] || fail "Claude settings must be a copy, not a link"

# A clean interactive start, with atuin on Ctrl-R (fzf keeps Ctrl-T) and the history import done
if [ "$mac" = 1 ]; then out=$(script -q /dev/null zsh -ic 'echo ZSH_OK; bindkey "^R"; bindkey "^T"; exit' 2>&1)
elif command -v script >/dev/null; then out=$(script -qec "zsh -ic 'echo ZSH_OK; bindkey \"^R\"; bindkey \"^T\"; exit'" /dev/null 2>&1)
else out=$(zsh -ic 'echo ZSH_OK; bindkey "^R"; bindkey "^T"' 2>&1 | grep -v "can't change option: zle"); fi
echo "$out" | grep -q ZSH_OK || fail "zsh failed: $out"
if echo "$out" | grep -E -i 'not found|error|no such file'; then fail "zsh startup printed errors"; fi
echo "$out" | grep -q 'atuin-search' || fail "Ctrl-R is not atuin's: $out"
echo "$out" | grep -q 'fzf-file-widget' || fail "Ctrl-T is not fzf's: $out"
[ -e "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/atuin-imported" ] || fail "the zsh step didn't import the history into atuin"
[ "$nvim_on" = 0 ] || nvim --headless "+Lazy! restore" +qa

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

if [ "${SIM:-1}" = 0 ]; then echo "verify: all good"; exit 0; fi
cd "$(mktemp -d)" # both simulators, end to end
# shellcheck disable=SC2016 # $display is SystemVerilog
printf 'module t; initial begin $display("sim ok"); $finish; end endmodule\n' >t.sv
{ iverilog -g2012 -o t.vvp t.sv && vvp t.vvp | grep -q 'sim ok'; } || fail "iverilog failed"
{ verilator --binary -Wno-fatal t.sv >/dev/null && ./obj_dir/Vt | grep -q 'sim ok'; } || fail "verilator failed"
echo "simulators: verilator $(verilator --version | cut -d' ' -f2), iverilog $(iverilog -V 2>&1 | head -n1 | cut -d' ' -f4)"
echo "verify: all good"
