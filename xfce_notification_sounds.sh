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
        # Strip the 'string' prefix and quotes from app_name
        cleaned_app_name=$(echo "$app_name" | sed 's/string "//g' | sed 's/"//g')
        cleaned_summary=$(echo "$summary" | sed 's/string "//g' | sed 's/"//g')
        cleaned_body=$(echo "$body" | sed 's/string "//g' | sed 's/"//g')
        
        if [[ "$cleaned_app_name" != "Spotify" && 
              $app_name != *"bash"* && 
              $app_name != *"terminal"* && 
              $app_name != *"script"* && 
              $cleaned_app_name != "KDocker" &&
              $summary != *"volume"* && 
              $summary != *"Volume"* && 
              $summary != *"audio"* && 
              $summary != *"Screen Brightness"* && 
              $summary != *"Brightness"* && 
              $summary != *"firefox"* && 
              $summary != *"firefox-developer-edition"* && 
              $summary != *"firefox-bin"* && 
              $summary != *"firefoxpwa"* &&
              $summary != *"FFPWA-01HST55A0FET5KX3VFERX8F0M6"* &&
              $summary != *"Voice"* &&
              $body != *"Voice - ("* &&
              $app_icon != *"terminal"* ]]; then
            
            paplay /home/user/Documents/System_Settings/aim2.wav &
        fi
    fi
done