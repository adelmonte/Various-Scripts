#!/bin/bash
# BRIGHTNESS CONTROL SCRIPT
# Usage: ./brightness_control.sh [up|down]

ACTION="$1"

# Get the backlight device path
BACKLIGHT_PATH="/sys/class/backlight/intel_backlight"
MAX_BRIGHTNESS=$(cat "$BACKLIGHT_PATH/max_brightness")
CURRENT_BRIGHTNESS=$(cat "$BACKLIGHT_PATH/actual_brightness")

# Calculate step size (1% of max for smooth transitions)
STEP=$((MAX_BRIGHTNESS * 1 / 100))

# Calculate minimum safe brightness (1% of max)
MIN_SAFE_BRIGHTNESS=$((MAX_BRIGHTNESS * 1 / 100))
# Ensure minimum safe brightness is at least 1
if [ $MIN_SAFE_BRIGHTNESS -lt 1 ]; then
    MIN_SAFE_BRIGHTNESS=1
fi

case "$ACTION" in
    "up")
        # Increase brightness by step
        NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS + STEP))
        # Ensure we don't exceed maximum
        if [ "$NEW_BRIGHTNESS" -gt "$MAX_BRIGHTNESS" ]; then
            NEW_BRIGHTNESS=$MAX_BRIGHTNESS
        fi
        ;;
    "down")
        # Decrease brightness by step
        NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS - STEP))
        # Ensure we don't go below minimum safe brightness
        if [ "$NEW_BRIGHTNESS" -lt "$MIN_SAFE_BRIGHTNESS" ]; then
            NEW_BRIGHTNESS=$MIN_SAFE_BRIGHTNESS
        fi
        ;;
    *)
        echo "Usage: $0 [up|down]"
        exit 1
        ;;
esac

# Write the new brightness value
echo "$NEW_BRIGHTNESS" > "$BACKLIGHT_PATH/brightness"

# Calculate percentage for notification
BRIGHTNESS_PERCENTAGE=$((NEW_BRIGHTNESS * 100 / MAX_BRIGHTNESS))

# Determine which icon to use
if [ "$BRIGHTNESS_PERCENTAGE" -eq 0 ]; then
    BRIGHTNESS_ICON="display-brightness-off-symbolic.svg"
elif [ "$BRIGHTNESS_PERCENTAGE" -lt 33 ]; then
    BRIGHTNESS_ICON="display-brightness-low-symbolic.svg"
elif [ "$BRIGHTNESS_PERCENTAGE" -lt 67 ]; then
    BRIGHTNESS_ICON="display-brightness-medium-symbolic.svg"
else
    BRIGHTNESS_ICON="display-brightness-high-symbolic.svg"
fi

# Send notification
notify-send --icon="/usr/share/icons/Papirus/16x16/symbolic/status/$BRIGHTNESS_ICON" \
            --hint=int:value:"${BRIGHTNESS_PERCENTAGE}" \
            --expire-time=2000 \
            -r 5555 \
            "Screen Brightness" "Brightness: ${BRIGHTNESS_PERCENTAGE}%"