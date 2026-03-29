#!/usr/bin/env bash

# Paths
WALLPAPER_DIR="$HOME/.dotfiles/wallpapers"
LN_PATH="$HOME/.cache/current_wallpaper.img"

# Ensure the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# 1. Pick a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# 2. Apply based on session type
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # Ensure swaybg is installed
    if ! command -v swaybg &> /dev/null; then
        notify-send "Wallpaper Error" "Please install 'swaybg'."
        exit 1
    fi

    # Kill existing swaybg instances before starting a new one
    pkill -x swaybg

    # Start swaybg in the background
    swaybg -i "$WALLPAPER" -m fill &

elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    # Ensure feh is installed
    if ! command -v feh &> /dev/null; then
        notify-send "Wallpaper Error" "Please install 'feh'."
        exit 1
    fi

    # Set wallpaper with feh
    feh --bg-fill "$WALLPAPER"

    # Update betterlockscreen cache in the background
    if command -v betterlockscreen &> /dev/null; then
        betterlockscreen -u "$WALLPAPER" --fx blur &
    fi
else
    notify-send "Wallpaper Error" "Unknown session type: $XDG_SESSION_TYPE"
    exit 1
fi

# 3. Create persistent symlink (useful for Wayland lockscreens or fetching current WP)
ln -sf "$WALLPAPER" "$LN_PATH"
