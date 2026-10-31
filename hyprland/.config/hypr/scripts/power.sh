#!/bin/sh
choice=$(printf 'shutdown\nreboot\n' | wmenu -i -b -p "power:" \
  -l 2 -f "Inconsolata Medium 12" -N 1a1a1a -n dadada \
	-M 9c6995 -m ffffff -S a8a1be -s 1a1a1a) || exit 0
case "$choice" in
	shutdown) systemctl poweroff ;;
	reboot) systemctl reboot ;;
esac
