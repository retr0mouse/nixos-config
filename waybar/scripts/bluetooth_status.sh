#!/usr/bin/env bash

adapter_powered=$(timeout 2 bluetoothctl show | awk -F': ' '/Powered:/ {print $2}')

if [ "$adapter_powered" != "yes" ]; then
    echo ""
    exit 0
fi

connected=$(timeout 2 bluetoothctl devices Connected | grep -q .)

if [ "$connected" ]; then
    device=$(bluetoothctl devices Connected | awk '{$1=$2=""; print substr($0,3)}')
    echo " $device"
else
    echo ""
fi
