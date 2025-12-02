#!/bin/bash
wifi=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
if [ -z "$wifi" ]; then
    echo "No Wi-Fi"
else
    echo "$wifi"
fi
exit 0


