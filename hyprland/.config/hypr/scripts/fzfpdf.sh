#!/bin/sh
dir="${PDF_DIR:-$HOME}"

if command -v fd >/dev/null 2>&1; then
	list=$(fd -e pdf -t f . "$dir")
else
	list=$(find "$dir" -type f -iname '*.pdf' -not -path '*/.*' 2>/dev/null)
fi

sel=$(printf '%s\n' "$list" | sed "s|^$dir/||" | wmenu -i -b -l 10 -p "pdf:" \
	-f "Inconsolata Medium 12" -N 1a1a1a -n dadada \
	-M 9c6995 -m ffffff -S a8a1be -s 1a1a1a) || exit 0

[ -n "$sel" ] && exec zathura "$dir/$sel"
