#!/bin/sh
# usage: idledim <light|medium|restore>
laptop=false
[ "$(uname -n)" = lovetrain ] && laptop=true

state="${XDG_RUNTIME_DIR:-/tmp}/idledim.brightness"

save() {
	[ -f "$state" ] || brightnessctl g > "$state"
}

case "$1" in
	light)
		if $laptop; then save; brightnessctl set 50%
		else hyprctl hyprsunset gamma 60; fi ;;
	medium)
		if $laptop; then save; brightnessctl -n 1 set 20%
		else hyprctl hyprsunset gamma 30; fi ;;
	restore)
		if $laptop; then
			if [ -f "$state" ]; then
				brightnessctl set "$(cat "$state")"
				rm -f "$state"
			fi
		else hyprctl hyprsunset reset gamma; fi ;;
esac
