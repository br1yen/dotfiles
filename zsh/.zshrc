# PATH (typeset -U dedupes entries)
typeset -U path
path=(~/.local/bin $path)

# Default editor
export EDITOR=nvim
export VISUAL=nvim

# nvim as man pager
export MANPAGER='nvim +Man!'

# Keep emacs-style line editing (see note below)
bindkey -e

# yazi autocd
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}

# Prompt: host:path $  (# for root)
PROMPT='%m:%~%(!.#.$) '

# Autosuggestions + accept with Ctrl-Y
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^Y' autosuggest-accept

# Completion
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

# zoxide (provides z and zi)
eval "$(zoxide init zsh)"

# aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
