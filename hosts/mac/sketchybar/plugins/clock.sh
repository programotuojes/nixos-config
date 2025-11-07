#!/usr/bin/env sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

week=$(date +%W)
ktu_week=$((week - 34))

sketchybar --set "$NAME" label="$(date "+($ktu_week) %W / 53, %b %d, %H:%M")"
