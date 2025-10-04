#!/bin/bash

sleep 0.2

if [ "$1" = "up" ]; then
    xdotool key --clearmodifiers "Page_Up"
elif [ "$1" = "down" ]; then
    xdotool key --clearmodifiers "Next"
fi