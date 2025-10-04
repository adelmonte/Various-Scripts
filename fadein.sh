#!/bin/bash

#xrandr --output eDP-1 --brightness 0 already set by xorg config

sleep 5

OUTPUT="eDP-1"
STEPS=20
DELAY=0.02

# Fade from 0.05 to 1.0
for i in $(seq 1 $STEPS); do
    brightness=$(awk "BEGIN {printf \"%.2f\", $i * 0.05}")
    xrandr --output "$OUTPUT" --brightness "$brightness"
    [[ $DELAY != 0 ]] && sleep "$DELAY"
done

xrandr --output "$OUTPUT" --set "Broadcast RGB" Full

redshift-gtk &


#xrandr --output eDP-1 --dpi 264
