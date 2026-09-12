# Shared zsh config sourced by both zshrc (macOS) and zshrc-arch (Linux).
# Platform files own PATH, plugins and tool init; this file owns behaviour
# that should be identical everywhere.

# ── Personal scripts (dotfiles/bin → ~/bin) ──────────────────────────
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# ── History extras ────────────────────────────────────────────────────
HISTSIZE=100000
SAVEHIST=100000
setopt INC_APPEND_HISTORY   # write each command as it runs, not at exit
setopt HIST_IGNORE_SPACE    # leading space keeps a command out of history
setopt HIST_VERIFY          # show !-expansions before running them

# ── Completion extras ─────────────────────────────────────────────────
setopt COMPLETE_IN_WORD     # tab-complete from the cursor, not just line end
# Stop word motions at / and . so Alt+arrows walk path segments
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

# ── Key bindings ──────────────────────────────────────────────────────
# Word movement: Shift+arrows (Alt+arrows live in the platform files)
bindkey '^[[1;2D' backward-word
bindkey '^[[1;2C' forward-word

# Home / End / Delete — cover normal, application-mode and legacy sequences
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[OH'  beginning-of-line
bindkey '^[OF'  end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char

# Delete previous word: Alt+Backspace, Alt+Delete, Shift+Backspace
bindkey '^[^?'      backward-kill-word
bindkey '^[[3;3~'   backward-kill-word
bindkey '^[[127;2u' backward-kill-word

# Alt+Y: copy the current command line to the clipboard via OSC52 (no execute).
# Works over SSH and inside tmux. (Alt+C is taken by fzf's cd widget.)
__copy_cmd_to_clipboard() {
  [[ -z "$BUFFER" ]] && return
  local encoded
  encoded=$(printf '%s' "$BUFFER" | base64 | tr -d '\n')
  if [[ -n "$TMUX" ]]; then
    printf '\033Ptmux;\033\033]52;c;%s\033\033\\\033\\' "$encoded"
  else
    printf '\033]52;c;%s\a' "$encoded"
  fi
  zle -M "Copied: $BUFFER"
}
zle -N __copy_cmd_to_clipboard
bindkey '^[y' __copy_cmd_to_clipboard

# ── Aliases ───────────────────────────────────────────────────────────
alias lrt='eza -la --icons --sort newest'   # long listing, newest last

# ── Functions ─────────────────────────────────────────────────────────
# Attach to (or create) the tmux session named "main"
mux() {
  if [[ -n "$TMUX" ]]; then
    echo "Already inside tmux"
    return 1
  fi
  if tmux has-session -t main 2>/dev/null; then
    tmux attach-session -t main
  else
    tmux new-session -s main
  fi
}

# ── Monokai Pro LS_COLORS (tab completion + ls fallback) ──────────────
# #ff6188 red · #fc9867 orange · #ffd866 yellow · #a9dc76 green
# #78dce8 cyan · #ab9df2 purple · #727072 gray
export LS_COLORS="\
di=38;2;120;220;232:\
ln=38;2;171;157;242:\
so=38;2;255;97;136:\
pi=38;2;252;152;103:\
ex=38;2;169;220;118:\
bd=38;2;255;216;102;48;2;45;42;46:\
cd=38;2;255;216;102;48;2;45;42;46:\
su=38;2;255;97;136;1:\
sg=38;2;252;152;103;1:\
tw=38;2;120;220;232;48;2;45;42;46:\
ow=38;2;120;220;232:\
st=38;2;120;220;232;1:\
or=38;2;255;97;136;1;4:\
mi=38;2;114;112;114;4:\
*.tar=38;2;255;97;136:*.tgz=38;2;255;97;136:*.gz=38;2;255;97;136:\
*.bz2=38;2;255;97;136:*.xz=38;2;255;97;136:*.zip=38;2;255;97;136:\
*.zst=38;2;255;97;136:*.7z=38;2;255;97;136:*.rar=38;2;255;97;136:\
*.jpg=38;2;171;157;242:*.jpeg=38;2;171;157;242:*.png=38;2;171;157;242:\
*.gif=38;2;171;157;242:*.bmp=38;2;171;157;242:*.svg=38;2;171;157;242:\
*.webp=38;2;171;157;242:*.ico=38;2;171;157;242:\
*.mp3=38;2;252;152;103:*.flac=38;2;252;152;103:*.wav=38;2;252;152;103:\
*.ogg=38;2;252;152;103:*.mp4=38;2;252;152;103:*.mkv=38;2;252;152;103:\
*.avi=38;2;252;152;103:*.mov=38;2;252;152;103:*.webm=38;2;252;152;103:\
*.pdf=38;2;255;97;136:*.doc=38;2;120;220;232:*.docx=38;2;120;220;232:\
*.xls=38;2;169;220;118:*.xlsx=38;2;169;220;118:\
*.py=38;2;255;216;102:*.js=38;2;255;216;102:*.ts=38;2;120;220;232:\
*.cc=38;2;120;220;232:*.cpp=38;2;120;220;232:*.h=38;2;169;220;118:\
*.rs=38;2;252;152;103:*.go=38;2;120;220;232:*.swift=38;2;252;152;103:\
*.sh=38;2;169;220;118:*.zsh=38;2;169;220;118:*.bash=38;2;169;220;118:\
*.md=38;2;114;112;114:*.txt=38;2;252;252;250:\
*.json=38;2;255;216;102:*.yaml=38;2;255;216;102:*.yml=38;2;255;216;102:\
*.toml=38;2;255;216;102:*.cfg=38;2;255;216;102:*.conf=38;2;255;216;102:\
*.log=38;2;114;112;114:*.bak=38;2;114;112;114:*.tmp=38;2;114;112;114:\
*.swp=38;2;114;112;114:*.o=38;2;114;112;114:*.a=38;2;114;112;114:\
*.so=38;2;171;157;242:*.enc=38;2;255;97;136"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# eza has its own colour keys — map the permission/size/date columns too
export EZA_COLORS="\
di=38;2;120;220;232:\
ln=38;2;171;157;242:\
ex=38;2;169;220;118:\
ur=38;2;255;216;102:uw=38;2;255;97;136:ux=38;2;169;220;118:\
gr=38;2;255;216;102:gw=38;2;255;97;136:gx=38;2;169;220;118:\
tr=38;2;255;216;102:tw=38;2;255;97;136:tx=38;2;169;220;118:\
sn=38;2;169;220;118:sb=38;2;169;220;118:\
da=38;2;114;112;114:\
uu=38;2;252;152;103:gu=38;2;252;152;103:\
un=38;2;255;97;136:gn=38;2;255;97;136"

# ── Machine-local overrides (API keys, work-specific paths — not tracked) ──
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
