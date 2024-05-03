#!/bin/bash

#this script is executed when the laptop lid is closed

# Function to check and kill a process
kill_process() {
    process_name=$1
    if pgrep -x "$process_name" > /dev/null; then
        echo "Killing $process_name"
        pkill -x "$process_name"
    fi
}

# Disable Bluetooth
echo "Disabling Bluetooth"
rfkill block bluetooth

# Check and kill processes
#kill_process "jamesdsp"
kill_process "spotify"
