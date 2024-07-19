#!/bin/bash

date_to_seconds() {
    date -d "$1" +%s
}
current_time=$(date +%s)

next_race=""
next_race_time=0

while IFS=',' read -r label startDate rest; do

    label=$(echo $label | sed 's/^{"label":"//' | sed 's/"$//')
    startDate=$(echo $startDate | sed 's/^"startDate":"//' | sed 's/"$//')
    
    if ! [[ $startDate =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        continue
    fi
    
    race_time=$(date_to_seconds "$startDate")
    
    if [[ $race_time -gt $current_time && ($next_race_time -eq 0 || $race_time -lt $next_race_time) ]]; then
        next_race="$label"
        next_race_time=$race_time
    fi
done <<EOF
$(curl -s https://www.espn.com/f1/schedule | grep -oP '{"label":"[^}]*}' | sed 's/}//' | grep '"startDate"')
EOF

if [[ -z $next_race ]]; then
    echo "No upcoming races found."
    exit 0
fi

start_date=$(date -d "@$next_race_time" "+%b %d-%d")
start_time=$(date -d "@$next_race_time" "+%H:%M")
days_until=$(( ($next_race_time - $current_time) / 86400 ))

echo "$next_race, $start_date - $start_time (in $days_until days)"
