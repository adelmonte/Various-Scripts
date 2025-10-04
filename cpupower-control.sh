#!/bin/bash
# /home/user/Documents/Scripts/cpupower-control.sh
# Auto-switch CPU profile based on AC power

power_source=$(cat /sys/class/power_supply/ADP1/online)

if [ "$power_source" -eq 1 ]; then
    # Plugged in - performance profile
    # Governor: performance, EPP: performance, Turbo: enabled
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu"
    done
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo "performance" > "$cpu"
    done
    echo "0" > /sys/devices/system/cpu/intel_pstate/no_turbo
else
    # On battery - balanced profile
    # Governor: powersave, EPP: balance_performance, Turbo: enabled
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "powersave" > "$cpu"
    done
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo "balance_performance" > "$cpu"
    done
    echo "0" > /sys/devices/system/cpu/intel_pstate/no_turbo
fi