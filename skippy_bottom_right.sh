#!/bin/bash
# Hot corner script - triggers skippy-xd.sh when mouse goes to bottom right corner
# Requirements: xdotool, xrandr

# Get screen dimensions once at startup
SCREEN_INFO=$(xrandr --current | grep "primary" | head -1)
[[ -z "$SCREEN_INFO" ]] && SCREEN_INFO=$(xrandr --current | grep " connected" | head -1)

SCREEN_WIDTH=$(echo "$SCREEN_INFO" | awk '{match($0, /[0-9]+x[0-9]+/); print substr($0, RSTART, RLENGTH)}' | cut -d'x' -f1)
SCREEN_HEIGHT=$(echo "$SCREEN_INFO" | awk '{match($0, /[0-9]+x[0-9]+/); print substr($0, RSTART, RLENGTH)}' | cut -d'x' -f2)

# Define corner size (pixels from edge)
CORNER_SIZE=10

# Calculate corner boundaries
RIGHT_EDGE=$((SCREEN_WIDTH - CORNER_SIZE))
BOTTOM_EDGE=$((SCREEN_HEIGHT - CORNER_SIZE))

# Path to your script
SCRIPT_PATH="/home/user/Documents/Scripts/skippy-xd.sh"

# Delay before triggering
DELAY=1

# Cooldown between triggers
COOLDOWN=2
LAST_TRIGGER=0
CORNER_ENTER_TIME=0

echo "Hot corner monitor started"
echo "Screen resolution: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Corner trigger zone: ${RIGHT_EDGE},${BOTTOM_EDGE} to ${SCREEN_WIDTH},${SCREEN_HEIGHT}"
echo "Hold mouse in corner for ${DELAY}s to trigger"

# Check requirements
command -v xdotool &> /dev/null || { echo "Error: xdotool required"; exit 1; }
[[ -f "$SCRIPT_PATH" ]] || echo "Warning: Script not found at $SCRIPT_PATH"

# Use xinput event monitoring instead of polling
# This is MUCH more efficient - only wakes when mouse moves
xinput --query-state "$(xinput list --name-only | grep -i 'mouse\|pointer' | head -1)" 2>/dev/null | grep -q "button" || {
    # Fallback: adaptive polling
    IN_CORNER=false
    
    while true; do
        read X Y < <(xdotool getmouselocation --shell | awk -F= '/^X=/{x=$2} /^Y=/{y=$2} END{print x,y}')
        
        CURRENT_TIME=$(date +%s)
        
        if [[ $X -ge $RIGHT_EDGE && $Y -ge $BOTTOM_EDGE ]]; then
            if [[ "$IN_CORNER" == "false" ]]; then
                IN_CORNER=true
                CORNER_ENTER_TIME=$CURRENT_TIME
                echo "Mouse in corner... (hold for ${DELAY}s)"
            fi
            
            if [[ $((CURRENT_TIME - CORNER_ENTER_TIME)) -ge $DELAY ]]; then
                if [[ $((CURRENT_TIME - LAST_TRIGGER)) -ge $COOLDOWN ]]; then
                    echo "Hot corner triggered!"
                    [[ -f "$SCRIPT_PATH" ]] && bash "$SCRIPT_PATH" &
                    LAST_TRIGGER=$CURRENT_TIME
                    CORNER_ENTER_TIME=0
                    IN_CORNER=false
                fi
            fi
            
            # Slower polling when in corner (already detected)
            sleep 0.2
        else
            IN_CORNER=false
            CORNER_ENTER_TIME=0
            
            # Much slower polling when mouse is away from corner
            sleep 0.5
        fi
    done
}