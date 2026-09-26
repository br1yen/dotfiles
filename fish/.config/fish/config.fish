# Vi mode
fish_vi_key_bindings

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
