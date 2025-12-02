# ~/.config/i3/toggle-opacity.sh
#!/bin/bash
if pgrep picom > /dev/null; then
    killall picom
else
    picom &
fi
