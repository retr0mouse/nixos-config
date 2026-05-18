#!/usr/bin/env bash

if ! command -v bluetoothctl >/dev/null; then
    echo ""
    exit 0
fi

adapter_powered=$(timeout 2 bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2}')

if [ "$adapter_powered" != "yes" ]; then
    echo ""
    exit 0
fi

if timeout 2 bluetoothctl devices Connected | grep -q .; then
    device=$(timeout 2 bluetoothctl devices Connected | awk '{$1=$2=""; print substr($0,3)}')
    echo " $device"
else
    echo ""
fi
