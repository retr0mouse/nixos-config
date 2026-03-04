#!/usr/bin/env bash

# Find AMD GPU card
CARD=$(ls /sys/class/drm | grep -E '^card[0-9]+$' | head -n1)

if [ -f "/sys/class/drm/card1/device/gpu_busy_percent" ]; then
    cat /sys/class/drm/card1/device/gpu_busy_percent | awk '{print $1 "%"}'
else
    echo "N/A"
fi
