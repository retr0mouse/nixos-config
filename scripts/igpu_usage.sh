#!/usr/bin/env bash

CARD=$(ls /sys/class/drm/ | grep -E '^card[0-9]+$' | while read c; do
    [ -f "/sys/class/drm/$c/device/gpu_busy_percent" ] && echo "$c" && break
done)

if [ -n "$CARD" ] && [ -f "/sys/class/drm/$CARD/device/gpu_busy_percent" ]; then
    awk '{print $1 "%"}' "/sys/class/drm/$CARD/device/gpu_busy_percent"
else
    echo "N/A"
fi
