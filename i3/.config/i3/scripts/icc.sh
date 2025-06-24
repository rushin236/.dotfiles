#!/bin/bash

# Function to show desktop notification
show_message() {
	local message="$1"
	notify-send "Message" "${message}"
}

# Path to ICC profile folder
ICC_DIR="$HOME/.config/i3/icc"

# Check if any .icc files exist
if ! compgen -G "$ICC_DIR/*.icc" >/dev/null; then
	show_message "No ICC profiles found in $ICC_DIR"
fi

# Apply ICC profile to each connected monitor
xrandr --query | grep " connected" | while read -r line; do
	MONITOR=$(echo "$line" | awk '{print $1}')
	ICC_PROFILE="$ICC_DIR/$MONITOR.icc"

	if [ -f "$ICC_PROFILE" ]; then
		dispwin -d "$MONITOR" "$ICC_PROFILE"
		show_message "Applied ICC profile for $MONITOR"
	else
		show_message "No ICC profile found for $MONITOR"
	fi
done
