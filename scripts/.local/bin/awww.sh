#!/usr/bin/env bash
DIR="${1:-$HOME/Sync/Pictures/paintings}"
INTERVAL="${2:-60}"

awww query >/dev/null 2>&1 || { awww-daemon & sleep 1; }

while true; do
    find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf |
    while read -r img; do
        awww img "$img" --resize fit --fill-color 000000 --transition-type fade --transition-duration 2 --transition-fps 60
        sleep "$INTERVAL"
    done
done
