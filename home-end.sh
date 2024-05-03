#!/bin/bash

# Determine the initial state (Home or End)
if [ -f "$HOME/.home_end_toggle" ]; then
  state=$(cat "$HOME/.home_end_toggle")
else
  state="home"
  echo "home" > "$HOME/.home_end_toggle"
fi

# Simulate the key press
if [ "$state" = "home" ]; then
  xdotool key --clearmodifiers "Insert"  
  xdotool key "Home"
  echo "end" > "$HOME/.home_end_toggle"
else
  xdotool key --clearmodifiers "Insert"  
  xdotool key "End"
  echo "home" > "$HOME/.home_end_toggle"
fi