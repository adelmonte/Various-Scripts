#!/bin/sh
# Center active window above XFCE bottom panel

# Get the active window geometry
eval $(xdotool getactivewindow getwindowgeometry --shell)

# Get window frame extents (decorations)
WINDOW_ID=$(xdotool getactivewindow)
FRAME_EXTENTS=$(xprop -id $WINDOW_ID _NET_FRAME_EXTENTS 2>/dev/null | cut -d'=' -f2 | tr -d ' ')

if [ -n "$FRAME_EXTENTS" ]; then
    FRAME_LEFT=$(echo "$FRAME_EXTENTS" | cut -d',' -f1)
    FRAME_RIGHT=$(echo "$FRAME_EXTENTS" | cut -d',' -f2)
    FRAME_TOP=$(echo "$FRAME_EXTENTS" | cut -d',' -f3)
    FRAME_BOTTOM=$(echo "$FRAME_EXTENTS" | cut -d',' -f4)
else
    FRAME_LEFT=0
    FRAME_RIGHT=0
    FRAME_TOP=0
    FRAME_BOTTOM=0
fi

# Get screen dimensions
SCREEN_INFO=$(xrandr --current | grep ' connected primary\|^\*' | head -1)
if [ -z "$SCREEN_INFO" ]; then
    SCREEN_INFO=$(xrandr --current | grep ' connected' | head -1)
fi

SCREEN_WIDTH=$(echo "$SCREEN_INFO" | grep -o '[0-9]*x[0-9]*' | cut -d'x' -f1)

# Get work area height (excludes bottom panel)
WORK_AREA=$(xprop -root _NET_WORKAREA | cut -d'=' -f2 | tr -d ' ')
WORK_HEIGHT=$(echo "$WORK_AREA" | cut -d',' -f4)

# Calculate total window dimensions including frames
TOTAL_WIDTH=$((WIDTH + FRAME_LEFT + FRAME_RIGHT))
TOTAL_HEIGHT=$((HEIGHT + FRAME_TOP + FRAME_BOTTOM))

# Calculate center position
xpos=$(( (SCREEN_WIDTH - TOTAL_WIDTH) / 2 ))
ypos=$(( (WORK_HEIGHT - TOTAL_HEIGHT) / 2 ))

# Move window
xdotool getactivewindow windowmove $xpos $ypos