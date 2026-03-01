#!/usr/bin/env bash

if command -v nvidia-smi &>/dev/null; then
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | awk '{print $1 "%"}'
else
    echo "N/A"
fi
