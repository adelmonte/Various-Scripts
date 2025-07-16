#!/bin/bash
# scope-auto.sh - Auto-attach scope-tui to active audio streams

find_active_sinks() {
    # Find sinks that currently have streams playing
    local active_sinks=()
    
    # Get all sink inputs (active streams)
    while IFS= read -r line; do
        if [[ $line =~ Sink:\ ([0-9]+) ]]; then
            sink_id="${BASH_REMATCH[1]}"
            # Get the sink name from the ID
            sink_name=$(pactl list short sinks | awk -v id="$sink_id" '$1 == id {print $2}')
            if [[ -n "$sink_name" && ! " ${active_sinks[*]} " =~ " ${sink_name} " ]]; then
                active_sinks+=("$sink_name")
            fi
        fi
    done < <(pactl list sink-inputs)
    
    printf '%s\n' "${active_sinks[@]}"
}

list_all_monitors() {
    pactl list short sources | grep '\.monitor$' | awk '{print $2}'
}

main() {
    echo "Scanning for active audio streams..."
    
    # Get active sinks and their monitors
    mapfile -t active_sinks < <(find_active_sinks)
    mapfile -t all_monitors < <(list_all_monitors)
    
    # Build options array
    options=()
    
    # Add active sink monitors first
    for sink in "${active_sinks[@]}"; do
        options+=("${sink}.monitor (♪ ACTIVE)")
    done
    
    # Add other monitors
    for monitor in "${all_monitors[@]}"; do
        # Skip if already added as active
        is_active=false
        for sink in "${active_sinks[@]}"; do
            if [[ "$monitor" == "${sink}.monitor" ]]; then
                is_active=true
                break
            fi
        done
        
        if [[ "$is_active" == false ]]; then
            options+=("$monitor")
        fi
    done
    
    if [[ ${#options[@]} -eq 0 ]]; then
        echo "No audio monitors found!"
        exit 1
    fi
    
    # Auto-select if only one active stream
    if [[ ${#active_sinks[@]} -eq 1 ]]; then
        selected="${active_sinks[0]}.monitor"
        echo "Auto-selecting active stream: $selected"
    else
        echo
        echo "Available audio streams:"
        for i in "${!options[@]}"; do
            echo "$((i+1)). ${options[i]}"
        done
        echo
        
        read -p "Select stream (1-${#options[@]}): " choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#options[@]} ]]; then
            selected="${options[$((choice-1))]}"
            # Remove the "♪ ACTIVE" suffix
            selected="${selected% (♪ ACTIVE)}"
        else
            echo "Invalid selection"
            exit 1
        fi
    fi
    
    echo "Launching scope-tui with: $selected"
    scope-tui --no-ui pulse "$selected"
}

main "$@"
