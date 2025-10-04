#!/bin/bash
STATE_FILE="/tmp/.home_end_toggle"

if [ -f "$STATE_FILE" ]; then
  state=$(cat "$STATE_FILE")
else
  state="home"
  echo "home" > "$STATE_FILE"
fi

if [ "$state" = "home" ]; then
  xdotool key Insert Home
  echo "end" > "$STATE_FILE"
else
  xdotool key Insert End
  echo "home" > "$STATE_FILE"
fi