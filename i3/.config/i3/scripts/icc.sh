#!/bin/bash

# Function to show desktop notification
show_message() {
	local message="$1"
	notify-send "Message" "${message}"
}

# Path to ICC profile folder
ICC_DIR="$HOME/.config/i3/icc"

# Check if any .icc or .icm files exist
if ! compgen -G "$ICC_DIR"/*.{icc,icm} >/dev/null; then
	show_message "No ICC profiles (.icc or .icm) found in $ICC_DIR"
	exit 1
fi

# Apply ICC profile to each connected monitor
xrandr --query | grep " connected" | while read -r line; do
	MONITOR=$(echo "$line" | awk '{print $1}')
	ICC_PROFILE_ICC="$ICC_DIR/$MONITOR.icc"
	ICC_PROFILE_ICM="$ICC_DIR/$MONITOR.icm"

	if [ -f "$ICC_PROFILE_ICC" ]; then
		dispwin -d "$MONITOR" "$ICC_PROFILE_ICC"
		show_message "Applied ICC profile ($MONITOR.icc) for $MONITOR"
	elif [ -f "$ICC_PROFILE_ICM" ]; then
		dispwin -d "$MONITOR" "$ICC_PROFILE_ICM"
		show_message "Applied ICC profile ($MONITOR.icm) for $MONITOR"
	else
		show_message "No ICC profile found for $MONITOR"
	fi
done
