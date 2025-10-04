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

get_volume() {
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Volume 2>/dev/null | grep -oP 'double \K[0-9.]+'
}

set_volume() {
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:org.mpris.MediaPlayer2.Player string:Volume variant:double:$1
}

case "$1" in
    "pause") spotify_dbus PlayPause ;;
    "play") spotify_dbus Play ;;
    "stop") spotify_dbus Stop ;;
    "next") spotify_dbus Next ;;
    "previous") spotify_dbus Previous ;;
    "volup")
        current=$(get_volume)
        new=$(echo "$current + 0.05" | bc)
        set_volume $new
        ;;
    "voldown")
        current=$(get_volume)
        new=$(echo "$current - 0.05" | bc)
        set_volume $new
        ;;
    *) echo "Usage: $0 [pause|play|stop|next|previous|volup|voldown]" ;;
esac