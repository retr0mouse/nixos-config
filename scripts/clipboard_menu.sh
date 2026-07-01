#!/usr/bin/env bash

cliphist list | rofi -dmenu -p "clipboard" -i | cliphist decode | wl-copy
