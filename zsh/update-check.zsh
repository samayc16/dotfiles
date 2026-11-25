# Asks once per new release whether to update these dotfiles:
#   dotfiles 2026.11.30 is available (you have 2026.11.24). Update now? [y/N]
# y runs `dotfiles update`; N is remembered for that version. zshrc sources this only in an
# interactive shell on a terminal, not in CI, and not with DOTFILES_NO_UPDATE_CHECK=1.
# Startup cost: one stat and one small file read, all builtins. The network lookup
# (`dotfiles check`) runs at most daily in a disowned background job, silent on any failure.
() {
  local state=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles cli=$DOTFILES/bin/dotfiles latest have
  local -a fresh=( $state/checked(N.mh-24) )
  (( $#fresh )) || { [[ -x $cli ]] && "$cli" check --quiet &>/dev/null &! }

  [[ -r $state/latest ]] && read -r latest <$state/latest
  [[ -n $latest && $latest != *[^0-9.]* && ! -e $state/asked/$latest ]] || return 0

  # Installed: a release's VERSION file, or a clone's newest tag (only reached when asking is possible)
  if [[ -r $DOTFILES/VERSION ]]; then
    read -r have <$DOTFILES/VERSION
  elif [[ -e $DOTFILES/.git ]]; then
    have=$(git -C $DOTFILES describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null)
    have=${have#v}
  fi
  autoload -Uz is-at-least
  [[ -n $have ]] && is-at-least $latest $have && return 0

  # One shell asks: a tmux restore opening ten panes at once must not ask ten times.
  zmodload -F zsh/files b:zf_mkdir 2>/dev/null || return 0
  zf_mkdir -p $state/asked 2>/dev/null && zf_mkdir $state/asked/$latest 2>/dev/null || return 0
  if read -q "?dotfiles $latest is available (you have ${have:-an untagged checkout}). Update now? [y/N] "; then
    print
    "$cli" update
  else
    print
  fi
}
