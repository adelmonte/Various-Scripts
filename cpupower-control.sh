#!/bin/bash

# Get current power source (AC or Battery)
power_source=$(cat /sys/class/power_supply/ADP1/online)

if [ "$power_source" -eq 1 ]; then
    # Laptop is plugged in
    cpupower-gui -b
    cpupower-gui ene --pref balance_performance
#    balooctl6 enable
    /home/user/Documents/Scripts/performance_optimized.sh
else
    # Laptop is unplugged
    cpupower-gui pr Battery
    cpupower-gui ene --pref power
#    balooctl6 disable
    /home/user/Documents/Scripts/battery_optimized.sh
fi

#performance