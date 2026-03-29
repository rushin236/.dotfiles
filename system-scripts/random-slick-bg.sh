#!/bin/bash

WALLPAPER_DIR="/usr/share/backgrounds/wallpapers"
CONFIG_FILE="/etc/lightdm/slick-greeter.conf"

# Pick a random image
RANDOM_WALL=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Update background line in config
sudo sed -i "s|^background=.*|background=$RANDOM_WALL|" "$CONFIG_FILE"
