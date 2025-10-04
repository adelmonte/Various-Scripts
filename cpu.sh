#!/bin/bash
# CPU Governor and EPP Profile Manager
# Usage: cpu-profile [performance|balanced|powersave|status|help]

# Default profile (used only when explicitly needed)
DEFAULT_PROFILE="balanced"

# Profile definitions: GOVERNOR EPP TURBO
declare -A PROFILES=(
    ["performance"]="performance performance 0"
    ["balanced"]="powersave balance_performance 0"
    ["powersave"]="powersave power 0"
)

# Function to set profile
set_profile() {
    local profile=$1
    local settings="${PROFILES[$profile]}"
    
    if [[ -z "$settings" ]]; then
        echo "Error: Invalid profile '$profile'"
        echo "Valid profiles: ${!PROFILES[@]}"
        exit 1
    fi
    
    read -r governor epp turbo <<< "$settings"
    
    echo "Setting profile: $profile"
    echo "  Governor: $governor"
    echo "  EPP: $epp"
    echo "  Turbo: $([ "$turbo" = "0" ] && echo "enabled" || echo "disabled")"
    
    # Set governor
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$governor" | sudo tee "$cpu" > /dev/null
    done
    
    # Set EPP
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo "$epp" | sudo tee "$cpu" > /dev/null
    done
    
    # Set turbo
    echo "$turbo" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    
    echo "✓ Profile applied successfully"
}

# Function to show status
show_status() {
    local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    local epp=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)
    local turbo=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo)
    local turbo_status=$([ "$turbo" = "0" ] && echo "enabled" || echo "disabled")
    
    # Detect current profile
    local current_profile="custom"
    for profile in "${!PROFILES[@]}"; do
        local settings="${PROFILES[$profile]}"
        read -r p_gov p_epp p_turbo <<< "$settings"
        if [[ "$governor" == "$p_gov" && "$epp" == "$p_epp" && "$turbo" == "$p_turbo" ]]; then
            current_profile="$profile"
            break
        fi
    done
    
    echo "Current CPU Profile: $current_profile"
    echo "---"
    echo "Governor: $governor"
    echo "EPP: $epp"
    echo "Turbo: $turbo_status"
    echo "---"
    echo "Frequencies (MHz):"
    grep MHz /proc/cpuinfo | awk '{print "  CPU" NR-1 ": " $4}' | head -8
}

# Function to show help
show_help() {
    cat << EOF
CPU Profile Manager

Usage: $(basename "$0") [COMMAND]

Commands:
  performance    Max performance (hot & fast)
  balanced       Fast response, cool & efficient (default)
  powersave      Maximum battery life
  status, st     Show current settings
  help           Show this help

Profiles:
  performance:  governor=performance, epp=performance, turbo=on
  balanced:     governor=powersave, epp=balance_performance, turbo=on
  powersave:    governor=powersave, epp=power, turbo=on

Examples:
  $(basename "$0") balanced
  $(basename "$0") st
EOF
}

# Main logic
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

case "$1" in
    performance|balanced|powersave)
        set_profile "$1"
        ;;
    status|st)
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Run '$(basename "$0") help' for usage"
        exit 1
        ;;
esac