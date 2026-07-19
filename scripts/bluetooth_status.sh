#!/usr/bin/env bash

if ! command -v bluetoothctl >/dev/null; then
    echo ""
    exit 0
fi

adapter_powered=$(timeout 2 bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2}')

if [ "$adapter_powered" != "yes" ]; then
    echo ""
    exit 0
fi

count=$(timeout 2 bluetoothctl devices Connected 2>/dev/null | wc -l)

if [ "$count" -gt 0 ]; then
    echo "󰂯 $count"
else
    echo ""
fi
