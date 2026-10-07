# PATH (typeset -U dedupes entries)
typeset -U path
path=(~/.local/bin $path)

# Default editor
export EDITOR=nvim
export VISUAL=nvim

# nvim as man pager
export MANPAGER='nvim +Man!'

bindkey -e

# Prompt: host:path $  (# for root)
PROMPT='%F{green}%B%m%b%f:%F{blue}%~%f %(!.#.$)%f '

# Autosuggestions + accept with Ctrl-Y
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^Y' autosuggest-accept

# Fuzzy reverse search
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# nnn
export NNN_OPTS="Hezx"
export NNN_BMS="d:$HOME/Downloads;s:$HOME/sync;c:$HOME/.config"
export NNN_TRASH="trash-put"
export NNN_OPENER="$HOME/.config/nnn/opener"

# aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fm='nnn'
alias vi='nvim'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gps='git push'
alias gpl='git pull'

alias t="tmux"            
alias tls="tmux ls"        
alias tn="tmux new -s"      
alias ta="tmux attach -t"    
alias td="tmux detach"        
alias tk="tmux kill-session -t"
alias tka="tmux kill-server"    
alias tm="tmux new-session -A -s"
