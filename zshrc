# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Display (XQuartz) ─────────────────────────────────────────────────
export DISPLAY=:0

# ── Path ──────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/opt/trash/bin:$HOME/.local/bin:$PATH"

# ── Powerlevel10k ─────────────────────────────────────────────────────
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── History ───────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ── Completion ────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# ── Key bindings ──────────────────────────────────────────────────────
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[Z' autosuggest-accept
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# ── Functions ────────────────────────────────────────────────────
mkcd() { mkdir -p "$1" && cd "$1" }

# ── Aliases ───────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat --paging=never'
alias lg='lazygit'
alias vim='nvim'
alias vi='nvim'
alias rm='trash'
alias img='kitten icat'
alias c='clear'
alias 1='cd ..'
alias 2='cd ../..'
alias 3='cd ../../..'
alias 4='cd ../../../..'
alias 5='cd ../../../../..'

# ── Environment ───────────────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export BAT_THEME='Monokai Extended'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── fzf ───────────────────────────────────────────────────────────────
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --color=fg:#f8f8f2,bg:#272822,hl:#f92672
  --color=fg+:#f8f8f2,bg+:#49483e,hl+:#f92672
  --color=info:#a6e22e,prompt:#f92672,pointer:#66d9ef
  --color=marker:#a6e22e,spinner:#ae81ff,header:#75715e
  --height=40% --layout=reverse --border'

# ── Mise (runtime version manager) ───────────────────────────────────
eval "$(mise activate zsh)"

# ── Zoxide (must be after compinit) ──────────────────────────────────
eval "$(zoxide init zsh)"

# ── Git delta ─────────────────────────────────────────────────────────
# Delta is configured via ~/.gitconfig (see git config setup)

# ── Plugins (keep at end) ─────────────────────────────────────────────
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
