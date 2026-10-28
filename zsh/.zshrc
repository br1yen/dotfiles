# PATH (typeset -U dedupes entries)
typeset -U path PATH
path=(~/.local/bin $path)
export PATH

# Default editor
export EDITOR=nvim
export VISUAL=nvim

bindkey -e
bindkey -r '\e'"'"
bindkey -r '\e"'

# nvim as man pager
export MANPAGER='nvim +Man!'

PROMPT='%F{magenta}%m%f %F{yellow}is in%f %F{green}%~%f %F{yellow}to%f '

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

bindkey '^[[Z' reverse-menu-complete

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# aliases
alias grep='grep --color=auto'
alias diff='diff --color=auto'

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
