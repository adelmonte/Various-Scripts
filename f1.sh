#!/bin/bash

# Colors for prettier output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to format time difference
format_time_diff() {
    local seconds=$1
    local days=$((seconds / 86400))
    local hours=$(( (seconds % 86400) / 3600 ))
    local minutes=$(( (seconds % 3600) / 60 ))
    local remaining_seconds=$((seconds % 60))
    
    echo "$days days, $hours hours, $minutes minutes, $remaining_seconds seconds"
}

# Get next race from F1Calendar API
get_next_race_f1calendar() {
    local year=$(date +"%Y")
    
    # Try to get data from f1calendar.com API
    local response=$(curl -s --max-time 10 "https://f1calendar.com/api/year/${year}")
    
    if [[ -n "$response" && "$response" == *"races"* ]]; then
        # Current date in YYYY-MM-DD format
        local current_date=$(date +"%Y-%m-%d")
        
        # Create a temporary file for the response
        local temp_file=$(mktemp)
        echo "$response" > "$temp_file"
        
        # Get all race names
        local all_races=$(grep -o '"name":"[^"]*"' "$temp_file")
        local race_locations=$(grep -o '"location":"[^"]*"' "$temp_file")
        local race_sessions=$(grep -o '"sessions":{[^}]*}' "$temp_file")
        
        # Number of races to process
        local race_count=$(echo "$all_races" | wc -l)
        
        # Arrays to store data
        declare -a race_names
        declare -a locations
        declare -a race_dates
        declare -a race_times
        
        # Extract race names
        while read -r line; do
            name=$(echo "$line" | cut -d'"' -f4)
            race_names+=("$name")
        done <<< "$all_races"
        
        # Extract locations
        while read -r line; do
            loc=$(echo "$line" | cut -d'"' -f4)
            locations+=("$loc")
        done <<< "$race_locations"
        
        # Extract race dates and times
        i=0
        while read -r session; do
            date_time=$(echo "$session" | grep -o '"gp":"[^"]*"' | cut -d'"' -f4)
            date=$(echo "$date_time" | cut -d'T' -f1)
            time=$(echo "$date_time" | cut -d'T' -f2)
            
            race_dates[$i]="$date"
            race_times[$i]="$time"
            ((i++))
        done <<< "$race_sessions"
        
        # Find the next race
        for ((i=0; i<$race_count; i++)); do
            if [[ "${race_dates[$i]}" > "$current_date" ]]; then
                # This is the next race
                race_name="${race_names[$i]}"
                location="${locations[$i]}"
                race_date="${race_dates[$i]}"
                race_time="${race_times[$i]}"
                
                # Determine circuit name based on location
                circuit_name=""
                case "$location" in
                    "Melbourne") circuit_name="Albert Park" ;;
                    "Shanghai") circuit_name="Shanghai International" ;;
                    "Suzuka") circuit_name="Suzuka" ;;
                    "Sakhir") circuit_name="Bahrain International" ;;
                    "Jeddah") circuit_name="Jeddah Corniche" ;;
                    "Miami") circuit_name="Miami International Autodrome" ;;
                    "Imola") circuit_name="Autodromo Enzo e Dino Ferrari" ;;
                    "Monte Carlo") circuit_name="Circuit de Monaco" ;;
                    "Catalunya") circuit_name="Circuit de Barcelona-Catalunya" ;;
                    "Montreal") circuit_name="Circuit Gilles Villeneuve" ;;
                    "Spielberg") circuit_name="Red Bull Ring" ;;
                    "Silverstone") circuit_name="Silverstone" ;;
                    "Spa-Francorchamps") circuit_name="Circuit de Spa-Francorchamps" ;;
                    "Budapest") circuit_name="Hungaroring" ;;
                    "Zandvoort") circuit_name="Circuit Zandvoort" ;;
                    "Monza") circuit_name="Autodromo Nazionale Monza" ;;
                    "Baku") circuit_name="Baku City" ;;
                    "Singapore") circuit_name="Marina Bay Street" ;;
                    "Austin") circuit_name="Circuit of The Americas" ;;
                    "Mexico City") circuit_name="Autódromo Hermanos Rodríguez" ;;
                    "Sao Paulo") circuit_name="Autódromo José Carlos Pace" ;;
                    "Las Vegas") circuit_name="Las Vegas Strip" ;;
                    "Doha") circuit_name="Lusail International" ;;
                    "Yas Marina") circuit_name="Yas Marina" ;;
                    *) circuit_name="$location" ;;
                esac
                
                # Create datetime for calculations
                race_datetime="${race_date}T${race_time}"
                
                # Convert to timestamps for countdown
                current_timestamp=$(date -u +%s)
                race_timestamp=$(date -u -d "$race_datetime" +%s)
                time_diff=$((race_timestamp - current_timestamp))
                
                # Format local time
                local_race_time=$(date -d "$race_datetime" +"%A, %B %d, %Y at %H:%M:%S %Z")
                
                # Display results
                echo -e "${GREEN}Next F1 Race: ${YELLOW}$race_name Grand Prix${NC}"
                echo -e "${GREEN}Circuit: ${NC}$circuit_name Circuit"
                echo -e "${GREEN}Location: ${NC}$location"
                echo -e "${GREEN}Race time (your local time): ${NC}$local_race_time"
                echo -e "${GREEN}Time remaining: ${YELLOW}$(format_time_diff $time_diff)${NC}"
                
                # Clean up
                rm -f "$temp_file"
                return 0
            fi
        done
        
        # Clean up
        rm -f "$temp_file"
    fi
    
    return 1
}

# Try to get F1 race info
if get_next_race_f1calendar; then
    exit 0
else
    echo -e "${RED}Unable to find information about the next F1 race.${NC}"
    echo -e "${YELLOW}Please check your internet connection or the F1 website.${NC}"
    exit 1
fi
