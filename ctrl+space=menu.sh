#!/bin/bash
WID=$(xdotool getactivewindow)
xdotool windowfocus $WID
sleep 0.1
xdotool key shift+F10