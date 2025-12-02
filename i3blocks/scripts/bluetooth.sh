#!/bin/bash
bt=$(bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{if($2=="yes") print "BT:On "; else print "BT:Off "}')
if [ -z "$bt" ]; then
    echo "BT N/A  w"
else
    echo "$bt"
fi
exit 0
