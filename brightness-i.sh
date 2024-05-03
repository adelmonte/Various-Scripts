#!/bin/bash

# Set the brightness using brillo
#brillo -u 250000 -A 5
brillo -A 1

max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
actual_brightness=$(cat /sys/class/backlight/intel_backlight/actual_brightness)
brightness_percentage=$((actual_brightness * 100 / max_brightness))

if [ "$brightness_percentage" -eq 0 ]; then
    brightness_icon="display-brightness-off-symbolic.svg"
elif [ "$brightness_percentage" -lt 33 ]; then
    brightness_icon="display-brightness-low-symbolic.svg"
elif [ "$brightness_percentage" -lt 67 ]; then
    brightness_icon="display-brightness-medium-symbolic.svg"
else
    brightness_icon="display-brightness-high-symbolic.svg"
fi


notify-send --icon="/usr/share/icons/Papirus-Dark/symbolic/status/$brightness_icon" \
            --hint=int:value:"${brightness_percentage}" \
            --expire-time=2000 \
            -r 5555 \
            "Screen Brightness" "Brightness: ${brightness_percentage}%"
