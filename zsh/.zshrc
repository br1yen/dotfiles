# Plugins
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source <(fzf --zsh)

# History
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY


# Completion
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
bindkey '^I' menu-complete
bindkey '^[[Z' reverse-menu-complete

# Vi Mode
function zvm_after_init() {
  bindkey -M vicmd '^R' fzf-history-widget
  bindkey -M viins '^R' fzf-history-widget
}

# Zsh Behavior
PROMPT='%m %~ $ '
setopt EXTENDED_GLOB
setopt CORRECT
