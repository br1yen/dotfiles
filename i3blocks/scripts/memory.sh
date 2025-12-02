#!/bin/bash
mem=$(free -h | awk '/Mem:/ {print $3"/"$2}')
if [ -z "$mem" ]; then
    echo "Mem N/A"
else
    echo "$mem"
fi
exit 0

