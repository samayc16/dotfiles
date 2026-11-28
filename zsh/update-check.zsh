# Tells you about a new release of these dotfiles. The first shell to see it asks:
#   dotfiles 2026.11.30 is available (you have 2026.11.24). Update now? [y/N]
# y runs `dotfiles update`. After N, every new shell says so in one line until you update:
#   dotfiles 2026.11.30 is available (you have 2026.11.24): dotfiles update
# Every new shell looks up the newest release (`dotfiles check`: one request to github.com) in a
# disowned background job, silent on any failure, at most once a minute so a tmux restore opening
# ten panes looks once. When that lookup finds a newer release, this same shell tells you before
# its next prompt (after your first command), so the first shell you open after a release says so.
# zshrc sources this only in an interactive shell on a terminal, not in CI, and not with
# DOTFILES_NO_UPDATE_CHECK=1. Startup cost: one stat and one small file read, all builtins.

typeset -g _dotfiles_state=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles _dotfiles_seen _dotfiles_lookup
typeset -gi _dotfiles_prompts=0

# Ask, or remind, about the release in the cache when it's newer than what's installed.
_dotfiles_offer_update() {
  local state=$_dotfiles_state cli=$DOTFILES/bin/dotfiles latest have
  [[ -r $state/latest ]] && read -r latest <$state/latest
  _dotfiles_seen=$latest
  [[ -n $latest && $latest != *[^0-9.]* ]] || return 0

  # Installed: a release's VERSION file, or a clone's newest tag (only reached when asking is possible)
  if [[ -r $DOTFILES/VERSION ]]; then
    read -r have <$DOTFILES/VERSION
  elif [[ -e $DOTFILES/.git ]]; then
    have=$(git -C $DOTFILES describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null)
    have=${have#v}
  fi
  autoload -Uz is-at-least
  [[ -n $have ]] && is-at-least $latest $have && return 0
  if [[ -e $state/asked/$latest ]]; then
    print -r -- "dotfiles $latest is available (you have ${have:-an untagged checkout}): dotfiles update"
    return 0
  fi

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

# precmd, until this shell's lookup is done: then tell about a release it found, once. Never at
# the first prompt, which powerlevel10k's instant prompt still counts as startup.
_dotfiles_after_lookup() {
  (( ++_dotfiles_prompts > 1 )) || return 0
  kill -0 $_dotfiles_lookup 2>/dev/null && return 0
  add-zsh-hook -d precmd _dotfiles_after_lookup
  local latest
  [[ -r $_dotfiles_state/latest ]] && read -r latest <$_dotfiles_state/latest
  [[ $latest == $_dotfiles_seen ]] || _dotfiles_offer_update
}

() {
  local cli=$DOTFILES/bin/dotfiles
  local -a recent=( $_dotfiles_state/checked(N.mm-1) )
  if (( ! $#recent )) && [[ -x $cli ]]; then
    "$cli" check --quiet &>/dev/null &!
    _dotfiles_lookup=$!
    autoload -Uz add-zsh-hook && add-zsh-hook precmd _dotfiles_after_lookup
  fi
  _dotfiles_offer_update
}
