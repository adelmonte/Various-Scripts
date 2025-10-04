#!/bin/bash

setup_xcape() {
    killall xcape 2>/dev/null
    sleep 0.5
    
    xmodmap - <<EOF
clear mod3
clear mod4
keycode 133 = Hyper_L
keycode 134 = Hyper_L
add mod3 = Hyper_L
EOF
    
    xcape -t 500 -e 'Hyper_L=Alt_L|F1'
}

# Initial setup
sleep 5
setup_xcape

# Monitor for input device changes 
udevadm monitor --udev --subsystem-match=input | while IFS= read -r line; do
    if [[ "$line" =~ (add|change).*(keyboard|input) ]]; then
        sleep 1
        setup_xcape
    fi
done