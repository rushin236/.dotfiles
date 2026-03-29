#!/bin/bash

USER="$1"
if [ -z "$USER" ]; then
    echo "Error: No user provided."
    exit 1
fi

USER_HOME="/home/$USER"

# ==========================================================
# CONFIGURATION
# ==========================================================
SHIKANE_CONF="$USER_HOME/.config/shikane/config.toml"
WALLPAPER_DIR="$USER_HOME/.dotfiles/wallpapers"

DEST_DIR="/etc/greetd"
DEST_SHIKANE="$DEST_DIR/shikane.toml"
DEST_WALLPAPER="$DEST_DIR/login-bg.jpg" # ReGreet will always look here

LOG_FILE="/var/log/sync-wayland-monitors.log"
# ==========================================================

: >"$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>"$LOG_FILE"
}

log "Running sync for user: $USER"
mkdir -p "$DEST_DIR"

# --- 1. Sync Shikane Config ---
if [[ -f "$SHIKANE_CONF" ]]; then
    if cp "$SHIKANE_CONF" "$DEST_SHIKANE"; then
        chmod 644 "$DEST_SHIKANE"
        log "Successfully copied Shikane config."
    else
        log "ERROR: Failed to copy Shikane config."
    fi
fi

# --- 2. Sync Random Wallpaper ---
if [[ -d "$WALLPAPER_DIR" ]]; then
    # Pick a random wallpaper just like your set-wallpaper.sh does
    RANDOM_WP=$(find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' \) | shuf -n 1)

    if [[ -n "$RANDOM_WP" ]]; then
        # Copy it to the static location ReGreet expects
        if cp "$RANDOM_WP" "$DEST_WALLPAPER"; then
            chmod 644 "$DEST_WALLPAPER"
            log "Successfully copied random wallpaper: $RANDOM_WP"
        else
            log "ERROR: Failed to copy wallpaper."
        fi
    else
        log "WARNING: No wallpapers found in $WALLPAPER_DIR"
    fi
else
    log "WARNING: Wallpaper directory missing at $WALLPAPER_DIR"
fi
