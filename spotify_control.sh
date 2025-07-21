#!/bin/bash

# Spotify Media Control Script
# Usage: ./spotify_control.sh [pause|next|previous|volup|voldown|play|stop]

spotify_dbus() {
    dbus-send \
        --print-reply \
        --dest=org.mpris.MediaPlayer2.spotify \
        /org/mpris/MediaPlayer2 \
        org.mpris.MediaPlayer2.Player.$1
}

case "$1" in
    "pause")
        spotify_dbus PlayPause
        ;;
    "play")
        spotify_dbus Play
        ;;
    "stop")
        spotify_dbus Stop
        ;;
    "next")
        spotify_dbus Next
        ;;
    "previous")
        spotify_dbus Previous
        ;;
    "volup")
        # Get Spotify's sink input and increase its volume
        spotify_sink=$(pactl list sink-inputs | grep -B 20 "spotify" | grep "Sink Input #" | tail -1 | cut -d'#' -f2)
        if [ -n "$spotify_sink" ]; then
            pactl set-sink-input-volume $spotify_sink +5%
        else
            echo "Spotify not found in audio streams"
        fi
        ;;
    "voldown")
        # Get Spotify's sink input and decrease its volume
        spotify_sink=$(pactl list sink-inputs | grep -B 20 "spotify" | grep "Sink Input #" | tail -1 | cut -d'#' -f2)
        if [ -n "$spotify_sink" ]; then
            pactl set-sink-input-volume $spotify_sink -5%
        else
            echo "Spotify not found in audio streams"
        fi
        ;;
    *)
        echo "Usage: $0 [pause|play|stop|next|previous|volup|voldown]"
        exit 1
        ;;
esac
