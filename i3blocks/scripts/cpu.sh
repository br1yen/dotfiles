#!/bin/bash
usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage)}')
if [ -z "$usage" ]; then
    echo "CPU N/A"
else
    echo "$usage%"
fi
exit 0
