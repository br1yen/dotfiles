#!/bin/sh
sel=$(cliphist list | wmenu -i -b -l 10 -p "clip:" \
	-f "Inconsolata Medium 12" -N 1a1a1a -n dadada \
	-M 9c6995 -m ffffff -S a8a1be -s 1a1a1a) || exit 0
[ -n "$sel" ] && printf '%s' "$sel" | cliphist decode | wl-copy
