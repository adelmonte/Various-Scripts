#!/bin/sh

#center active window to center screen

eval $(xdotool getactivewindow getwindowgeometry --shell)

xpos=$(( (4100 - WIDTH) / 2 ))
ypos=$(( (2640 - HEIGHT) / 2 ))

xdotool getactivewindow windowmove $xpos $ypos