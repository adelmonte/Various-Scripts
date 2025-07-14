#!/bin/bash

# F1 Race Information Script
# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Global variables
CACHE_DIR="/tmp/f1_cache"
CACHE_EXPIRY=3600

# Create cache directory
mkdir -p "$CACHE_DIR"

# Function to format time difference
format_time_diff() {
    local seconds=$1
    local days=$((seconds / 86400))
    local hours=$(( (seconds % 86400) / 3600 ))
    local minutes=$(( (seconds % 3600) / 60 ))
    
    if [[ $days -gt 0 ]]; then
        echo "$days days, $hours hours"
    elif [[ $hours -gt 0 ]]; then
        echo "$hours hours, $minutes minutes"
    else
        echo "$minutes minutes"
    fi
}

# Function to format date/time
format_datetime() {
    local datetime="$1"
    date -d "$datetime" +"%A, %B %d at %H:%M %Z" 2>/dev/null || echo "$datetime"
}

# Cache function
get_cached_or_fetch() {
    local url="$1"
    local cache_file="$2"
    
    if [[ -f "$cache_file" && $(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0) )) -lt $CACHE_EXPIRY ]]; then
        cat "$cache_file"
        return 0
    fi
    
    local response=$(curl -s --max-time 15 -H "User-Agent: Mozilla/5.0" "$url")
    if [[ -n "$response" && "$response" != *"error"* ]]; then
        echo "$response" > "$cache_file"
        echo "$response"
        return 0
    fi
    
    return 1
}

# Get circuit info
get_circuit_info() {
    local location="$1"
    case "$location" in
        "Melbourne") echo "Albert Park Circuit|Australia" ;;
        "Shanghai") echo "Shanghai International Circuit|China" ;;
        "Suzuka") echo "Suzuka International Racing Course|Japan" ;;
        "Sakhir") echo "Bahrain International Circuit|Bahrain" ;;
        "Jeddah") echo "Jeddah Corniche Circuit|Saudi Arabia" ;;
        "Miami") echo "Miami International Autodrome|United States" ;;
        "Imola") echo "Autodromo Enzo e Dino Ferrari|Italy" ;;
        "Monte Carlo") echo "Circuit de Monaco|Monaco" ;;
        "Catalunya") echo "Circuit de Barcelona-Catalunya|Spain" ;;
        "Montreal") echo "Circuit Gilles Villeneuve|Canada" ;;
        "Spielberg") echo "Red Bull Ring|Austria" ;;
        "Silverstone") echo "Silverstone Circuit|United Kingdom" ;;
        "Spa-Francorchamps") echo "Circuit de Spa-Francorchamps|Belgium" ;;
        "Budapest") echo "Hungaroring|Hungary" ;;
        "Zandvoort") echo "Circuit Zandvoort|Netherlands" ;;
        "Monza") echo "Autodromo Nazionale Monza|Italy" ;;
        "Baku") echo "Baku City Circuit|Azerbaijan" ;;
        "Singapore") echo "Marina Bay Street Circuit|Singapore" ;;
        "Austin") echo "Circuit of The Americas|United States" ;;
        "Mexico City") echo "Autódromo Hermanos Rodríguez|Mexico" ;;
        "Sao Paulo") echo "Autódromo José Carlos Pace|Brazil" ;;
        "Las Vegas") echo "Las Vegas Strip Circuit|United States" ;;
        "Doha") echo "Lusail International Circuit|Qatar" ;;
        "Yas Marina") echo "Yas Marina Circuit|UAE" ;;
        *) echo "$location Circuit|Unknown" ;;
    esac
}

# Display session times
display_session_times() {
    local sessions="$1"
    
    echo -e "\n${RED} Weekend Schedule:${NC}"
    
    local fp1=$(echo "$sessions" | grep -o '"fp1":"[^"]*"' | cut -d'"' -f4)
    local fp2=$(echo "$sessions" | grep -o '"fp2":"[^"]*"' | cut -d'"' -f4)
    local fp3=$(echo "$sessions" | grep -o '"fp3":"[^"]*"' | cut -d'"' -f4)
    local qualifying=$(echo "$sessions" | grep -o '"qualifying":"[^"]*"' | cut -d'"' -f4)
    local sprint=$(echo "$sessions" | grep -o '"sprint":"[^"]*"' | cut -d'"' -f4)
    local race=$(echo "$sessions" | grep -o '"gp":"[^"]*"' | cut -d'"' -f4)
    
    [[ -n "$fp1" ]] && echo -e " ${YELLOW}FP1:${NC}        $(format_datetime "$fp1")"
    [[ -n "$fp2" ]] && echo -e " ${YELLOW}FP2:${NC}        $(format_datetime "$fp2")"
    [[ -n "$fp3" && -z "$sprint" ]] && echo -e " ${YELLOW}FP3:${NC}        $(format_datetime "$fp3")"
    [[ -n "$sprint" ]] && echo -e " ${MAGENTA}Sprint:${NC}     $(format_datetime "$sprint")"
    [[ -n "$qualifying" ]] && echo -e " ${CYAN}Qualifying:${NC} $(format_datetime "$qualifying")"
    [[ -n "$race" ]] && echo -e "${GREEN} Race:${NC}       $(format_datetime "$race")"
}

# Format race name
format_race_name() {
    local name="$1"
    name=$(echo "$name" | sed 's/Grand Prix/GP/g')
    [[ ! "$name" =~ "GP" ]] && name="${name} GP"
    echo "$name"
}

# Main function
get_f1_race_info() {
    local year=$(date +"%Y")
    local f1_cache="$CACHE_DIR/f1_calendar_${year}.json"
    local response=$(get_cached_or_fetch "https://f1calendar.com/api/year/${year}" "$f1_cache")
    
    if [[ -n "$response" && "$response" == *"races"* ]]; then
        local current_date=$(date +"%Y-%m-%d")
        local current_timestamp=$(date -u +%s)
        
        # Arrays to store race data
        declare -a race_names
        declare -a locations  
        declare -a race_dates
        declare -a race_sessions
        declare -a is_upcoming
        
        # Extract race information
        local i=0
        while IFS= read -r race_block; do
            local name=$(echo "$race_block" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
            local location=$(echo "$race_block" | grep -o '"location":"[^"]*"' | head -1 | cut -d'"' -f4)
            local sessions=$(echo "$race_block" | grep -o '"sessions":{[^}]*}' | head -1)
            local race_datetime=$(echo "$sessions" | grep -o '"gp":"[^"]*"' | cut -d'"' -f4)
            local race_date=$(echo "$race_datetime" | cut -d'T' -f1)
            
            if [[ -n "$name" && -n "$location" && -n "$race_date" ]]; then
                race_names[$i]=$(format_race_name "$name")
                locations[$i]="$location"
                race_dates[$i]="$race_date"
                race_sessions[$i]="$sessions"
                
                if [[ "$race_date" > "$current_date" ]]; then
                    is_upcoming[$i]=1
                else
                    is_upcoming[$i]=0
                fi
                ((i++))
            fi
        done < <(echo "$response" | grep -o '{[^}]*"name":"[^"]*"[^}]*"sessions":{[^}]*}[^}]*}')
        
        # Find and display next race
        local next_race_found=0
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}${RED}                        NEXT RACE${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        
        for ((i=0; i<${#race_names[@]}; i++)); do
            if [[ ${is_upcoming[$i]} -eq 1 && $next_race_found -eq 0 ]]; then
                local circuit_info=$(get_circuit_info "${locations[$i]}")
                local circuit_name=$(echo "$circuit_info" | cut -d'|' -f1)
                local country=$(echo "$circuit_info" | cut -d'|' -f2)
                
                local race_date_time=$(echo "${race_sessions[$i]}" | grep -o '"gp":"[^"]*"' | cut -d'"' -f4)
                local race_timestamp=$(date -u -d "$race_date_time" +%s 2>/dev/null || echo 0)
                local time_diff=$((race_timestamp - current_timestamp))
                
                echo -e "\n${RED} Race:${NC}       ${YELLOW}${race_names[$i]}${NC}"
                echo -e "${RED} Circuit:${NC}    $circuit_name"
                echo -e "${RED} Location:${NC}   ${locations[$i]}, $country"
                echo -e "${GREEN} Race Time:${NC}  $(format_datetime "$race_date_time")"
                echo -e "${GREEN} Time Until:${NC} ${YELLOW}$(format_time_diff $time_diff)${NC}"
                
                display_session_times "${race_sessions[$i]}"
                
                next_race_found=1
                break
            fi
        done
        
        # Display season calendar
        echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}${RED}                    $year SEASON CALENDAR${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        
        local round=1
        for ((i=0; i<${#race_names[@]}; i++)); do
            local circuit_info=$(get_circuit_info "${locations[$i]}")
            local circuit_name=$(echo "$circuit_info" | cut -d'|' -f1)
            local race_date_time=$(echo "${race_sessions[$i]}" | grep -o '"gp":"[^"]*"' | cut -d'"' -f4)
            local race_date=$(echo "$race_date_time" | cut -d'T' -f1)
            local formatted_date=$(date -d "$race_date" +"%b %d" 2>/dev/null || echo "$race_date")
            
            local status_color=""
            local status_symbol=""
            if [[ ${is_upcoming[$i]} -eq 1 ]]; then
                if [[ $round -eq $((next_race_found + $(echo "${race_names[@]:0:$i}" | wc -w))) ]]; then
                    status_color="$YELLOW"
                    status_symbol="> "
                else
                    status_color="$GREEN"
                    status_symbol="  "
                fi
            else
                status_color="$NC"
                status_symbol="* "
            fi
            
            printf "${status_color}%s%2d. %-18s %-8s %-30s${NC}\n" "$status_symbol" "$round" "${race_names[$i]}" "$formatted_date" "$circuit_name"
            ((round++))
        done
        echo
        
        return 0
    else
        echo -e "${RED}Unable to fetch F1 race information.${NC}"
        return 1
    fi
}

# Parse arguments (simplified)
while getopts "ch" opt; do
    case $opt in
        c) rm -rf "$CACHE_DIR"; mkdir -p "$CACHE_DIR"; echo "Cache cleared."; exit 0 ;;
        h) echo "Usage: $0 [-c] [-h]"; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done

# Execute
get_f1_race_info
