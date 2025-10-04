#!/bin/bash

declare -A keymap=(
    ["1"]="j"
    ["2"]="k"
    ["3"]="l"
    ["4"]="u"
    ["5"]="i"
    ["6"]="o"
    ["7"]="7"
    ["8"]="8"
    ["9"]="9"
    ["0"]="m"
)

sleep 0.2

if [ -n "${keymap[$1]}" ]; then
    xdotool key --clearmodifiers "Control+Alt+${keymap[$1]}"
    xdotool type --clearmodifiers "$1"
fi