#!/bin/bash

USER="$1"
USER_HOME="/home/$USER"
LASTUSED="$USER_HOME/.config/autorandr/lastUsed"
DEST_DIR="/etc/xdg/autorandr/"
LOG_FILE="/var/log/monitors-copy.log"
: >$LOG_FILE

# Create log function for consistency
log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>"$LOG_FILE"
	# Uncomment below to also log to system journal
	# logger -t copy-lastused "$1"
}

log "Running copy-lastused for user: $USER"
log "Checking if lastUsed exists at: $LASTUSED"

if [[ -d "$LASTUSED" ]]; then
	if [[ ! -d $DEST_DIR ]]; then
		log "$DEST_DIR not present creating one"
		mkdir -p "$DEST_DIR"
	fi
	log "$DEST_DIR present"
	if cp -r "$LASTUSED" "$DEST_DIR"; then
		log "Successfully copied: $LASTUSED -> $DEST_DIR"
	else
		log "ERROR: Failed to copy $LASTUSED to $DEST_DIR"
	fi
else
	log "WARNING: lastUsed autorandr profile missing at: $LASTUSED"
fi
