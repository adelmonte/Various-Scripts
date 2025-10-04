#!/bin/bash
# VOLUME CONTROL SCRIPT
# Usage: ./volume_control.sh [up|down|mute]

ACTION="$1"

# Get current volume and mute status using pactl
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1
}

get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

case "$ACTION" in
    "up")
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        ;;
    "down")
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;
    "mute")
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    *)
        echo "Usage: $0 [up|down|mute]"
        exit 1
        ;;
esac

# Get current status
VOLUME=$(get_volume)
MUTED=$(get_mute)

# Determine icon and message
if [ "$MUTED" = "yes" ]; then
    VOLUME_ICON="audio-volume-muted-symbolic.svg"
    MESSAGE="Volume: Muted"
elif [ "$VOLUME" -eq 0 ]; then
    VOLUME_ICON="audio-volume-muted-symbolic.svg"
    MESSAGE="Volume: ${VOLUME}%"
elif [ "$VOLUME" -lt 33 ]; then
    VOLUME_ICON="audio-volume-low-symbolic.svg"
    MESSAGE="Volume: ${VOLUME}%"
elif [ "$VOLUME" -lt 67 ]; then
    VOLUME_ICON="audio-volume-medium-symbolic.svg"
    MESSAGE="Volume: ${VOLUME}%"
else
    VOLUME_ICON="audio-volume-high-symbolic.svg"
    MESSAGE="Volume: ${VOLUME}%"
fi

# Send notification
notify-send --icon="/usr/share/icons/Papirus/16x16/symbolic/status/$VOLUME_ICON" \
            --hint=int:value:"${VOLUME}" \
            --expire-time=2000 \
            -r 6666 \
            "Volume Control" "$MESSAGE"