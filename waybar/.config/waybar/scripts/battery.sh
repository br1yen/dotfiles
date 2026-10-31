#!/bin/bash

if ls /sys/class/power_supply/ | grep -q '^BAT'; then
    capacity=$(cat /sys/class/power_supply/BAT*/capacity | head -n1)
    echo "$capacity%"
else
    echo "All"
fi
