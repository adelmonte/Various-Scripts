#!/bin/bash
# BRIGHTNESS CONTROL SCRIPT
# Usage: ./brightness_control.sh [up|down]

ACTION="$1"
BACKLIGHT_PATH="/sys/class/backlight/intel_backlight"

# Read values once
read -r MAX_BRIGHTNESS < "$BACKLIGHT_PATH/max_brightness"
read -r CURRENT_BRIGHTNESS < "$BACKLIGHT_PATH/actual_brightness"

# Calculate step and minimum (1% of max)
STEP=$((MAX_BRIGHTNESS / 100))
MIN_SAFE_BRIGHTNESS=$((MAX_BRIGHTNESS / 100))
[[ $MIN_SAFE_BRIGHTNESS -lt 1 ]] && MIN_SAFE_BRIGHTNESS=1

case "$ACTION" in
    up)
        NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS + STEP))
        [[ $NEW_BRIGHTNESS -gt $MAX_BRIGHTNESS ]] && NEW_BRIGHTNESS=$MAX_BRIGHTNESS
        ;;
    down)
        NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS - STEP))
        [[ $NEW_BRIGHTNESS -lt $MIN_SAFE_BRIGHTNESS ]] && NEW_BRIGHTNESS=$MIN_SAFE_BRIGHTNESS
        ;;
    *)
        echo "Usage: $0 [up|down]"
        exit 1
        ;;
esac

# Write new brightness
echo "$NEW_BRIGHTNESS" > "$BACKLIGHT_PATH/brightness"

# Calculate percentage
BRIGHTNESS_PERCENTAGE=$((NEW_BRIGHTNESS * 100 / MAX_BRIGHTNESS))

# Determine icon
if [[ $BRIGHTNESS_PERCENTAGE -eq 0 ]]; then
    ICON="display-brightness-off-symbolic.svg"
elif [[ $BRIGHTNESS_PERCENTAGE -lt 33 ]]; then
    ICON="display-brightness-low-symbolic.svg"
elif [[ $BRIGHTNESS_PERCENTAGE -lt 67 ]]; then
    ICON="display-brightness-medium-symbolic.svg"
else
    ICON="display-brightness-high-symbolic.svg"
fi

# Send notification
notify-send --icon="/usr/share/icons/Papirus/16x16/symbolic/status/$ICON" \
            --hint=int:value:"$BRIGHTNESS_PERCENTAGE" \
            --expire-time=2000 \
            -r 5555 \
            "Screen Brightness" "Brightness: ${BRIGHTNESS_PERCENTAGE}%"