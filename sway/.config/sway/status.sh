#!/bin/sh

while :; do
    out=$(date +'%Y-%m-%d %H:%M')

    for bat in /sys/class/power_supply/BAT*; do
        [ -d "$bat" ] || continue
        out="BAT $(cat "$bat/capacity")% ($(cat "$bat/status")) | $out"
        break
    done

    echo "$out"
    sleep 5
done
