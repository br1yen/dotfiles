#!/bin/bash
vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}')
if [ -z "$vol" ]; then
    echo "Vol N/A"
else
    echo "$vol"
fi
exit 0



