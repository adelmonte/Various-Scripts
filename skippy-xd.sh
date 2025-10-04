#!/bin/bash
# Skippy-XD wrapper script: Excludes xpad windows dynamically and includes hidden apps (e.g., Spotify)
# by temporarily overriding _NET_WM_STATE_SKIP_TASKBAR for visibility in exposè/switch.
# Usage: ./skippy-xd-wrapper.sh [--expose|--switch] [additional options like --next, --prev]
# Assumes Spotify uses WM_CLASS "spotify", "Spotify" (common on Linux); adjust detection/regex if needed.
# This script runs on demand (e.g., via keybind); it's not a background process.

# Handle command line arguments
SKIPPY_OPTS="$@"
if [ $# -eq 0 ]; then
    SKIPPY_OPTS="--expose"
fi

# Detect Spotify windows (for override)
detect_spotify() {
    wmctrl -lx 2>/dev/null | grep "spotify.Spotify" | awk '{print $1}'
}

# Override: Remove _NET_WM_STATE_SKIP_TASKBAR temporarily
override_state() {
    local winids=$(detect_spotify)
    if [ -n "$winids" ]; then
        for winid in $winids; do
            xprop -id "$winid" -remove _NET_WM_STATE >/dev/null 2>&1
        done
        sleep 0.2
    fi
}

# Restore: Re-add _NET_WM_STATE_SKIP_TASKBAR
restore_state() {
    local winids=$(detect_spotify)
    if [ -n "$winids" ]; then
        for winid in $winids; do
            xprop -id "$winid" -f _NET_WM_STATE 32a \
                -set _NET_WM_STATE '_NET_WM_STATE_SKIP_TASKBAR' >/dev/null 2>&1
        done
        sleep 0.2
    fi
}

# Check and override Spotify if present
has_spotify=false
if [ -n "$(detect_spotify)" ]; then
    has_spotify=true
    override_state
fi

# Extract unique classes, exclude xpad
classes=$(wmctrl -lx 2>/dev/null | awk 'NF >= 3 { wc=$3; if (index(wc,".")>0) sub(/^[^.]+\./,"",wc); if (wc != "xpad") print wc }' | sort -u | grep .)

# Force include Spotify variants
if ! echo "$classes" | grep -q -E "(^Spotify$|^spotify$)"; then
    classes=$(echo -e "Spotify\nspotify\n$classes" | sort -u | grep .)
fi

# Run Skippy-XD
if [ -z "$classes" ]; then
    skippy-xd $SKIPPY_OPTS >/dev/null 2>&1
else
    # Escaped regex for filter
    escaped=$(echo "$classes" | sed 's/[\[\].*+?^$(){}|\/\\-]/\\&/g' | paste -sd'|')
    regex="($escaped)"
    skippy-xd $SKIPPY_OPTS --wm-class "$regex" >/dev/null 2>&1 || \
    skippy-xd $SKIPPY_OPTS --wm-class "(Spotify|spotify|kitty|firefox|dolphin)" >/dev/null 2>&1 || \
    skippy-xd $SKIPPY_OPTS >/dev/null 2>&1
fi

# Restore if overridden
if [ "$has_spotify" = true ]; then
    restore_state
fi