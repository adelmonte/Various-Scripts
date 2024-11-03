#!/bin/bash

dbus-monitor "interface='org.freedesktop.Notifications'" | \
while read -r line; do
    if [[ $line == *"method call"* && $line == *"Notify"* ]]; then
        # Read multiple lines to capture the full notification details
        read -t 1 app_name
        read -t 1 replaces_id
        read -t 1 app_icon
        read -t 1 summary
        read -t 1 body

        # Check if the notification is from a bash script
        # Common identifiers for bash-triggered notifications
        if [[ $app_name != *"bash"* && 
              $app_name != *"terminal"* && 
              $app_name != *"script"* && 
              $summary != *"volume"* && 
              $summary != *"Volume"* && 
              $summary != *"audio"* && 
              $summary != *"Screen Brightness"* && 
              $summary != *"Brightness"* && 
              $summary != *"spotify"* && 
              $summary != *"Spotify"* && 
              $summary != *"firefox"* && 
              $summary != *"firefox-developer-edition"* && 
              $app_icon != *"terminal"* ]]; then
            
            # For debugging (optional)
            # echo "App: $app_name"
            # echo "Summary: $summary"
            # echo "Body: $body"
            
            paplay /home/user/Documents/System_Settings/aim2.wav &
        fi
    fi
done