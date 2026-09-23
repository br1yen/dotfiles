export MANPAGER='nvim +Man!'
export EDITOR=nvim
export VISUAL=nvim
export PATH="$PATH:$HOME/.local/bin"

# Yazi change directory helper
function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

## History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

## Completions
autoload -Uz compinit
# Cache compdump to avoid slow startup latency
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m+1) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Tab completion navigation
bindkey '^I' menu-complete
bindkey '^[[Z' reverse-menu-complete

## Prompt
PROMPT='%m %~ $ '
setopt EXTENDED_GLOB
unsetopt CORRECT  # Prevents annoying "correct 'cmd' to 'c' [nyae]?" checks

## Plugins
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

function zvm_after_init() {
  source <(fzf --zsh)
  
  # Ensure Tab menu completion still works in vi insert mode
  bindkey -M viins '^I' menu-complete
  bindkey -M viins '^[[Z' reverse-menu-complete
}
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

## Alisases
alias 'ta'='tmux attach'

alias 'gs'='git status'
alias 'ga'='git add'
alias 'gc'='git commit'
alias 'gps'='git push'
alias 'gpl'='git pull'
