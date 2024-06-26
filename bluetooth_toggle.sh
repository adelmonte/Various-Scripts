#!/bin/bash

# Function to kill a process forcefully
kill_process() {
    local process_name="$1"
    pkill -9 -f "$process_name"
}

# Function to start a process in the background if not running
start_process() {
    local process_command=("$@")
    local process_name="${process_command[*]}"
    if ! pgrep -f "${process_command[*]}" > /dev/null; then
        nohup "${process_command[@]}" > /dev/null 2>&1 &
        disown
    fi
}

# Check the current state of Bluetooth
if rfkill list bluetooth | grep -q "Soft blocked: yes"; then

    # Turn on Bluetooth
    rfkill unblock bluetooth

    # Start jamesdsp and spotify with environment variable
    start_process "jamesdsp" "-t"
    start_process "bash" "-c" "env LD_PRELOAD=/usr/lib/spotify-adblock.so spotify --uri=%U"

else
    # Turn off Bluetooth
    rfkill block bluetooth

    # Kill running instances of jamesdsp and spotify
    kill_process "jamesdsp"
    kill_process "spotify"
    
fi
