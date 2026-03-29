#!/usr/bin/env bash

# 1. Kill all running instances of Waybar
killall -q waybar

# 2. Wait until the processes have completely shut down to prevent overlap
while pgrep -u $UID -x waybar >/dev/null; do sleep 0.1; done

# 3. Launch Waybar in the background
waybar &

# Optional: Send a notification so you know it reloaded successfully
notify-send "Waybar" "Reloaded successfully"
