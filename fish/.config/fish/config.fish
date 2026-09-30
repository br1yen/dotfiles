# Default editor
set -Ux EDITOR nvim
set -Ux VISUAL nvim

# nvim as man pager
set -Ux MANPAGER 'nvim +Man!'

# yazi autocd
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	command rm -f -- "$tmp"
end

# Cursor shapes
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore

# Binds
bind -M insert \cy accept-autosuggestion

# Prompt
function fish_prompt
    set -l symbol '$'

    if fish_is_root_user
        set symbol '#'
    end

    printf '%s:%s%s ' $hostname (prompt_pwd) $symbol
end

# No beep
set -g fish_greeting
